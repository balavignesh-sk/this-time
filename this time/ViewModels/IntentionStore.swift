import Foundation
import Observation

@MainActor
@Observable
final class IntentionStore {
    private(set) var history: [SessionHistoryEntry]
    private(set) var services: [Service]
    private(set) var intention: IntentionPreferences
    private(set) var blockingEnabled: Bool
    private(set) var activeSessions: [String: UUID] = [:]
    var unlockedService: Service?
    var notice: String?
    private(set) var pendingPresentation: Presentation?

    struct Presentation: Identifiable {
        let id: UUID
        let service: Service
        let prompt: IntentionPrompt
    }

    @ObservationIgnored private let blocking: any BlockingClient
    @ObservationIgnored private let preferences: any AppPreferences
    @ObservationIgnored private let notifications: any SessionNotifications

    init(blocking: any BlockingClient, preferences: any AppPreferences, notifications: any SessionNotifications) {
        self.blocking = blocking
        self.preferences = preferences
        self.notifications = notifications
        services = preferences.loadServices()
        history = preferences.loadHistory().sorted { $0.startedAt > $1.startedAt }
        intention = preferences.intentionPreferences
        blockingEnabled = preferences.blockingEnabled
    }

    var isBlockingAvailable: Bool { blocking.isAvailable }

    func authorizeBlocking() async throws { try await blocking.authorize() }

    func finishOnboarding() {
        intention.onboardingComplete = true
        preferences.intentionPreferences = intention
    }

    func requestNotifications() async { await notifications.requestAuthorization() }

    func setUnlockMinutes(_ minutes: Int) {
        guard [5, 15, 30].contains(minutes) else { return }
        intention.unlockMinutes = minutes
        preferences.intentionPreferences = intention
    }

    func addAlternative(_ text: String) {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        intention.alternatives.append(.init(text: text))
        preferences.intentionPreferences = intention
    }

    func updateAlternative(_ activity: AlternativeActivity, text: String) {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let index = intention.alternatives.firstIndex(where: { $0.id == activity.id }) else { return }
        intention.alternatives[index].text = text
        preferences.intentionPreferences = intention
    }

    func removeAlternative(_ activity: AlternativeActivity) {
        intention.alternatives.removeAll { $0.id == activity.id }
        preferences.intentionPreferences = intention
    }

    @discardableResult
    func addSelection(_ selection: [Service]) -> Bool {
        var updated = services
        for service in selection where !updated.contains(where: {
            $0.id == service.id ||
            (service.applicationTokenData != nil && $0.applicationTokenData == service.applicationTokenData) ||
            (service.webDomainTokenData != nil && $0.webDomainTokenData == service.webDomainTokenData) ||
            (service.categoryTokenData != nil && $0.categoryTokenData == service.categoryTokenData)
        }) { updated.append(service) }
        return saveServices(updated)
    }

    func remove(_ service: Service) { _ = saveServices(services.filter { $0.id != service.id }) }

    private func saveServices(_ updated: [Service]) -> Bool {
        do {
            try blocking.apply(services: updated, enabled: blockingEnabled)
            do { try preferences.saveServices(updated) }
            catch {
                try? blocking.apply(services: services, enabled: blockingEnabled)
                throw error
            }
            services = updated
            refreshBlocking()
            return true
        } catch {
            notice = error.localizedDescription
            return false
        }
    }

    func enableBlocking() async {
        do {
            try await blocking.authorize()
            try blocking.apply(services: services, enabled: true)
            blockingEnabled = true
            preferences.blockingEnabled = true
            refreshBlocking()
        } catch { notice = error.localizedDescription }
    }

    func disableBlocking() {
        blocking.clear()
        blockingEnabled = false
        preferences.blockingEnabled = false
        activeSessions = [:]
        pendingPresentation = nil
        unlockedService = nil
    }

    func refreshBlocking() {
        guard blocking.isAuthorized else {
            if blockingEnabled { disableBlocking() }
            return
        }
        do {
            try blocking.apply(services: services, enabled: blockingEnabled)
            activeSessions = try blocking.activeSessions()
            if let request = try blocking.pendingRequest(),
               let service = services.first(where: { $0.id == request.itemID }) {
                if pendingPresentation?.id != request.id {
                    unlockedService = nil
                    pendingPresentation = Presentation(
                        id: request.id, service: service,
                        prompt: .make(service: service, history: history, alternatives: intention.alternatives)
                    )
                }
            } else { pendingPresentation = nil }
        } catch { notice = error.localizedDescription }
    }

    func requestUnlock(_ service: Service) {
        guard blockingEnabled else {
            notice = String(localized: "Enable protection before requesting an unlock.")
            return
        }
        do {
            try blocking.requestUnlock(for: service)
            refreshBlocking()
        } catch { notice = error.localizedDescription }
    }

    func relock(_ service: Service) {
        guard let id = activeSessions[service.id] else { return }
        blocking.endSession(id)
        refreshBlocking()
        if activeSessions[service.id] != nil {
            notice = String(localized: "Couldn’t lock this item. Please try again.")
        }
    }

    func cancelPendingIntention(requestID: UUID) {
        guard pendingPresentation?.id == requestID else { return }
        blocking.cancelRequest(requestID)
        pendingPresentation = nil
    }

    @discardableResult
    func decide(requestID: UUID, answer: String, unlock: Bool, minutes: Int) -> Bool {
        guard SessionPolicy.allowedMinutes.contains(minutes) else {
            notice = String(localized: "Choose between 1 and 240 minutes.")
            return false
        }
        let answer = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count >= 10, let request = pendingPresentation, request.id == requestID else { return false }
        let id = UUID()
        do {
            // Revalidate the cross-process request before acting on a presented prompt.
            guard blockingEnabled, try blocking.pendingRequest()?.id == requestID else {
                refreshBlocking()
                notice = String(localized: "This request expired. Choose the item again in Rules.")
                return false
            }
            if unlock {
                try blocking.beginSession(service: request.service, requestID: request.id, sessionID: id,
                                          minutes: minutes, reason: answer, isSnooze: false)
            }
            let entry = SessionHistoryEntry(id: id, service: request.service, intention: answer,
                                            startedAt: Date(), minutes: minutes,
                                            isSnooze: false, prompt: request.prompt.text, didUnlock: unlock)
            let updated = [entry] + history
            do {
                try preferences.saveHistory(updated)
                history = updated
            } catch {
                if !unlock { throw error }
                history = updated
                notice = String(localized: "Access was granted, but your intention couldn’t be saved.")
            }
            if !unlock { blocking.cancelRequest(requestID) }
            if unlock {
                pendingPresentation = nil
                unlockedService = request.service
            }
            activeSessions = (try? blocking.activeSessions()) ?? activeSessions
            return true
        } catch {
            notice = error.localizedDescription
            return false
        }
    }

    func clearHistory() {
        do {
            try preferences.saveHistory([])
            history = []
        } catch { notice = error.localizedDescription }
    }
}

import Foundation
#if os(iOS) && FAMILY_CONTROLS
import FamilyControls
import ManagedSettings
import DeviceActivity

@MainActor
final class AppBlocking: BlockingClient {
    var isAvailable: Bool { true }
    var isAuthorized: Bool { AuthorizationCenter.shared.authorizationStatus == .approved }
    private let center = DeviceActivityCenter()

    func authorize() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        guard isAuthorized else { throw BlockingError.notAuthorized }
    }

    func apply(services: [Service], enabled: Bool) throws {
        try ScreenTimeShared.update { state in
            state.enabled = enabled && isAuthorized
            state.items = services.map {
                ScreenTimeShared.Item(id: $0.id, application: $0.applicationTokenData,
                                      website: $0.webDomainTokenData, category: $0.categoryTokenData)
            }
            let ids = Set(state.items.map(\.id))
            state.sessions.removeAll { !ids.contains($0.itemID) }
            if !state.enabled {
                state.sessions = []
                state.request = nil
            }
        }
        cleanupSessions()
    }

    func clear() {
        try? ScreenTimeShared.update { state in
            state.enabled = false
            state.sessions = []
            state.request = nil
        }
        ManagedSettingsStore(named: ScreenTimeShared.storeName).clearAllSettings()
        cleanupSessions()
    }

    func activeSessions() throws -> [String: UUID] {
        try ScreenTimeShared.update { state in
            var result: [String: UUID] = [:]
            for session in state.sessions { result[session.itemID] = session.id }
            // Website unlocks intentionally apply to the whole website selection.
            if let session = state.sessions.first(where: { session in
                state.items.contains { $0.id == session.itemID && $0.website != nil }
            }) {
                for item in state.items where item.website != nil { result[item.id] = session.id }
            }
            return result
        }
    }

    func requestUnlock(for service: Service) throws {
        guard isAuthorized else { throw BlockingError.notAuthorized }
        try ScreenTimeShared.update { state in
            guard state.enabled, state.items.contains(where: { $0.id == service.id }) else {
                throw BlockingError.missingRequest
            }
            state.request = .init(itemID: service.id, isSnooze: false)
        }
    }

    func pendingRequest() throws -> BlockingRequest? {
        try ScreenTimeShared.update { state in
            guard state.enabled, let request = state.request else { return nil }
            return BlockingRequest(id: request.id, itemID: request.itemID)
        }
    }

    func cancelRequest(_ id: UUID?) {
        try? ScreenTimeShared.update { state in
            if state.request?.id == id { state.request = nil }
        }
    }

    func beginSession(service: Service, requestID: UUID, sessionID: UUID, minutes: Int, reason: String, isSnooze: Bool) throws {
        guard isAuthorized else { throw BlockingError.notAuthorized }
        guard SessionPolicy.allowedMinutes.contains(minutes), reason.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10 else {
            throw BlockingError.invalidLimit
        }
        let decoder = JSONDecoder()
        let apps = try service.applicationTokenData.map { [try decoder.decode(ApplicationToken.self, from: $0)] } ?? []
        let categories = try service.categoryTokenData.map { [try decoder.decode(ActivityCategoryToken.self, from: $0)] } ?? []
        let isWebsite = service.webDomainTokenData != nil
        guard isWebsite || !apps.isEmpty || !categories.isEmpty else { throw BlockingError.missingRequest }
        let now = Date()
        let end = now.addingTimeInterval(Double(isWebsite ? minutes * 60 : 24 * 60 * 60))
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        // DeviceActivity requires a 15-minute interval. A warning ends short website
        // grants at the intended deadline; the interval end remains a fallback.
        let monitorEnd = isWebsite ? now.addingTimeInterval(Double(max(15, minutes) * 60)) : end
        let schedule = DeviceActivitySchedule(
            intervalStart: Calendar.current.dateComponents(components, from: now),
            intervalEnd: Calendar.current.dateComponents(components, from: monitorEnd),
            repeats: false,
            warningTime: isWebsite && minutes < 15 ? DateComponents(minute: 15 - minutes) : nil
        )
        let name = DeviceActivityName(ScreenTimeShared.activityPrefix + sessionID.uuidString)
        var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
        if !isWebsite {
            events[.init(ScreenTimeShared.usageEventName)] = DeviceActivityEvent(
                applications: Set(apps), categories: Set(categories),
                threshold: DateComponents(minute: minutes), includesPastActivity: false
            )
        }
        // Register enforcement before granting access. A failed registration never unlocks.
        try center.startMonitoring(name, during: schedule, events: events)
        do {
            try ScreenTimeShared.update { state in
                guard state.enabled, state.request?.id == requestID,
                      state.request?.itemID == service.id,
                      state.items.contains(where: { $0.id == service.id }) else {
                    throw BlockingError.missingRequest
                }
                state.sessions.removeAll { $0.itemID == service.id }
                state.sessions.append(.init(id: sessionID, itemID: service.id, end: end,
                                            reason: reason, minutes: minutes))
                state.request = nil
            }
            cleanupSessions()
        } catch {
            ScreenTimeShared.stopSession(sessionID)
            throw error
        }
    }

    func endSession(_ id: UUID) {
        try? ScreenTimeShared.update { state in state.sessions.removeAll { $0.id == id } }
        cleanupSessions()
    }

    private func cleanupSessions() {
        guard let state = try? ScreenTimeShared.snapshot() else { return }
        let active = Set(state.sessions.map(\.id))
        for activity in center.activities where activity.rawValue.hasPrefix(ScreenTimeShared.activityPrefix) {
            if let id = UUID(uuidString: String(activity.rawValue.dropFirst(ScreenTimeShared.activityPrefix.count))),
               !active.contains(id) { ScreenTimeShared.stopSession(id) }
        }
    }

    enum BlockingError: LocalizedError {
        case notAuthorized, missingRequest, invalidLimit
        var errorDescription: String? {
            switch self {
            case .notAuthorized: String(localized: "Allow Screen Time access to protect your selected items.")
            case .missingRequest: String(localized: "This request has expired. Choose the item again in Rules.")
            case .invalidLimit: String(localized: "Write at least 10 characters and choose between 1 and 240 minutes.")
            }
        }
    }
}
#endif

import Foundation
#if os(iOS) && (FAMILY_CONTROLS || SCREEN_TIME_EXTENSION)
import Darwin
import ManagedSettings
import DeviceActivity
import UserNotifications

/// Atomic cross-process intention requests, active grants, and shield reconciliation.
nonisolated enum ScreenTimeShared {
    static let groupID = "group.com.vigneshcorp.thistime"
    static let storeName = ManagedSettingsStore.Name("thisTime.blocking")
    static let activityPrefix = "thisTime.session."
    static let idlePrefix = "thisTime.idle."
    static let schedulePrefix = "thisTime.schedule."
    static let usageEventName = "usageLimit"

    struct Item: Codable {
        let id: String
        let application: Data?
        let website: Data?
        var category: Data? = nil
    }

    struct Request: Codable, Identifiable {
        var id = UUID()
        let itemID: String
        var created = Date()
        var isSnooze: Bool? = nil
    }

    struct Session: Codable {
        let id: UUID
        let itemID: String
        let end: Date
        var reason: String? = nil
        var minutes: Int? = nil
        var lastActivity: Date? = nil
        var midpointSent: Bool? = nil
    }

    struct State: Codable {
        var usageTimingVersion: Int? = nil
        var enabled = false
        var items: [Item] = []
        var sessions: [Session] = []
        var request: Request?
    }

    enum StorageError: Error { case unavailable, lockFailed, invalidSelection, scheduledBlock }

    static func snapshot() throws -> State {
        guard let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            throw StorageError.unavailable
        }
        let url = directory.appendingPathComponent("screen-time.json")
        guard FileManager.default.fileExists(atPath: url.path) else { return State() }
        return try JSONDecoder().decode(State.self, from: Data(contentsOf: url))
    }

    /// Serializes writes and shield updates across the app and extensions.
    static func update<T>(_ operation: (inout State) throws -> T) throws -> T {
        guard let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            throw StorageError.unavailable
        }
        let descriptor = open(directory.appendingPathComponent("screen-time.lock").path, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
        guard descriptor >= 0 else { throw StorageError.lockFailed }
        defer { close(descriptor) }
        guard flock(descriptor, LOCK_EX) == 0 else { throw StorageError.lockFailed }
        defer { flock(descriptor, LOCK_UN) }
        var state = try snapshot()
        reconcile(&state, at: Date())
        // Roll back to reconciled shields; migration may have stopped old monitors.
        let original = state
        let result = try operation(&state)
        do {
            let data = try JSONEncoder().encode(state)
            try apply(state)
            try data.write(to: directory.appendingPathComponent("screen-time.json"), options: .atomic)
            return result
        } catch {
            try? apply(original)
            throw error
        }
    }

    static func reconcile(_ state: inout State, at now: Date) {
        // Version 2 removes legacy cooldowns, schedules, and inactivity monitors.
        if state.usageTimingVersion != 2 {
            for session in state.sessions { stopSession(session.id) }
            let oldSchedules = DeviceActivityCenter().activities.filter { $0.rawValue.hasPrefix(schedulePrefix) }
            DeviceActivityCenter().stopMonitoring(oldSchedules)
            state.sessions = []
            state.request = nil
            state.usageTimingVersion = 2
        }
        let expired = state.sessions.filter { $0.end <= now }
        state.sessions.removeAll { $0.end <= now }
        for session in expired { stopSession(session.id) }
        if let request = state.request,
           now.timeIntervalSince(request.created) >= 300 || !state.items.contains(where: { $0.id == request.itemID }) {
            state.request = nil
        }
    }

    static func apply(_ state: State) throws {
        let store = ManagedSettingsStore(named: storeName)
        guard state.enabled else { store.clearAllSettings(); return }
        let now = Date()
        let unlocked = Set(state.sessions.filter { $0.end > now }.map(\.itemID))
        let blocked = state.items.filter { !unlocked.contains($0.id) }
        let decoder = JSONDecoder()
        let apps = try Set(blocked.compactMap(\.application).map { try decoder.decode(ApplicationToken.self, from: $0) })
        let websites = try Set(blocked.compactMap(\.website).map { try decoder.decode(WebDomainToken.self, from: $0) })
        let categories = try Set(blocked.compactMap(\.category).map { try decoder.decode(ActivityCategoryToken.self, from: $0) })
        let unlockedApps = try Set(state.items.filter { unlocked.contains($0.id) }.compactMap(\.application).map { try decoder.decode(ApplicationToken.self, from: $0) })
        let anyWebsiteUnlocked = state.items.contains { $0.website != nil && unlocked.contains($0.id) }
        guard apps.count <= 50, websites.count <= 50 else { throw StorageError.invalidSelection }
        store.shield.applications = apps.isEmpty ? nil : apps
        store.shield.webDomains = anyWebsiteUnlocked || websites.isEmpty ? nil : websites
        store.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories, except: unlockedApps)
    }

    static func itemID(in state: State, application: ApplicationToken?, website: WebDomainToken?, category: ActivityCategoryToken? = nil) -> String? {
        let decoder = JSONDecoder()
        return state.items.first { item in
            if let application, let data = item.application {
                return (try? decoder.decode(ApplicationToken.self, from: data)) == application
            }
            if let website, let data = item.website {
                return (try? decoder.decode(WebDomainToken.self, from: data)) == website
            }
            if let category, let data = item.category {
                return (try? decoder.decode(ActivityCategoryToken.self, from: data)) == category
            }
            return false
        }?.id
    }

    static func request(application: ApplicationToken? = nil, website: WebDomainToken? = nil, category: ActivityCategoryToken? = nil) throws {
        try update { state in
            // Website tokens can differ across processes. Since website grants cover
            // the whole selected set, use a selected website as the request identity.
            let selectedID = itemID(in: state, application: application, website: website, category: category)
                ?? (website != nil ? state.items.first(where: { $0.website != nil })?.id : nil)
            guard state.enabled, let id = selectedID else {
                throw StorageError.invalidSelection
            }
            state.request = Request(itemID: id, isSnooze: false)
        }
    }

    static func stopSession(_ id: UUID) {
        DeviceActivityCenter().stopMonitoring([
            DeviceActivityName(activityPrefix + id.uuidString),
            DeviceActivityName(idlePrefix + id.uuidString)
        ])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["midpoint." + id.uuidString])
    }

}
#endif

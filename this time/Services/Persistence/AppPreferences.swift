import Foundation

/// App-local preferences. Screen Time's cross-process state belongs to BlockingClient.
@MainActor
protocol AppPreferences: AnyObject {
    func loadHistory() -> [SessionHistoryEntry]
    func saveHistory(_ entries: [SessionHistoryEntry]) throws
    func loadServices() -> [Service]
    func saveServices(_ services: [Service]) throws
    var blockingEnabled: Bool { get set }
    var lastReasons: [String: String] { get set }
    var intentionPreferences: IntentionPreferences { get set }
}

@MainActor
final class UserDefaultsAppPreferences: AppPreferences {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadHistory() -> [SessionHistoryEntry] {
        guard let data = defaults.data(forKey: "thisTime.sessionHistory.v1") else { return [] }
        return (try? JSONDecoder().decode([SessionHistoryEntry].self, from: data)) ?? []
    }

    func saveHistory(_ entries: [SessionHistoryEntry]) throws {
        defaults.set(try JSONEncoder().encode(entries), forKey: "thisTime.sessionHistory.v1")
    }

    // Keep existing keys so restructuring does not discard installed users' settings.
    func loadServices() -> [Service] {
        guard let data = defaults.data(forKey: "thisTime.services.v1"),
              let services = try? JSONDecoder().decode([Service].self, from: data) else { return [] }
        return services.filter { $0.applicationTokenData != nil || $0.webDomainTokenData != nil || $0.categoryTokenData != nil }
    }

    func saveServices(_ services: [Service]) throws {
        defaults.set(try JSONEncoder().encode(services), forKey: "thisTime.services.v1")
    }

    var intentionPreferences: IntentionPreferences {
        get {
            guard let data = defaults.data(forKey: "thisTime.reflection.v1"),
                  let value = try? JSONDecoder().decode(IntentionPreferences.self, from: data) else { return .init() }
            return value
        }
        set { if let data = try? JSONEncoder().encode(newValue) { defaults.set(data, forKey: "thisTime.reflection.v1") } }
    }

    var blockingEnabled: Bool {
        get { defaults.bool(forKey: "thisTime.blockingEnabled.v1") }
        set { defaults.set(newValue, forKey: "thisTime.blockingEnabled.v1") }
    }

    var lastReasons: [String: String] {
        get { defaults.dictionary(forKey: "thisTime.lastReasons") as? [String: String] ?? [:] }
        set { defaults.set(newValue, forKey: "thisTime.lastReasons") }
    }

}

#if os(iOS)
import ActivityKit
import Foundation

/// Shared by the app, Screen Time extensions, and the Live Activity extension.
nonisolated struct IntentionActivityAttributes: ActivityAttributes {
    enum Timing: String, Codable {
        case usage
        case elapsed
    }

    struct ContentState: Codable, Hashable {
        let confirmedUsedMinutes: Int
        let reportedAt: Date
        var ended = false
    }

    let sessionID: UUID
    let intention: String
    let minutes: Int
    let timing: Timing
    let startedAt: Date
    let deadline: Date
    var applicationTokenData: Data? = nil
    var webDomainTokenData: Data? = nil
    var categoryTokenData: Data? = nil

    func remainingMinutes(for state: ContentState) -> Int {
        max(0, minutes - max(0, state.confirmedUsedMinutes))
    }

    func staleDate(for state: ContentState) -> Date {
        timing == .elapsed ? deadline : min(deadline, state.reportedAt.addingTimeInterval(90))
    }
}
#endif

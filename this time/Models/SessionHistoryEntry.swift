import Foundation

/// A intention and its decision, not a measurement of actual screen time.
struct SessionHistoryEntry: Codable, Identifiable {
    let id: UUID
    let service: Service
    let intention: String
    let startedAt: Date
    let minutes: Int
    let isSnooze: Bool
    var prompt: String? = nil
    var didUnlock: Bool? = nil

    // Older history only recorded successful unlocks.
    var unlocked: Bool { didUnlock ?? true }
}

import Foundation

/// Pure, shared timing and schedule rules. No Screen Time or UI dependencies.
nonisolated enum SessionExpiryPolicy {
    struct Settings: Codable, Equatable {
        var snoozeMinutes = 2
        var resetMinutes = 15
        var cooldownEnabled = true

        init() {}

        private enum CodingKeys: String, CodingKey {
            case snoozeMinutes, resetMinutes, cooldownEnabled
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            snoozeMinutes = try values.decodeIfPresent(Int.self, forKey: .snoozeMinutes) ?? 2
            resetMinutes = try values.decodeIfPresent(Int.self, forKey: .resetMinutes) ?? 15
            cooldownEnabled = try values.decodeIfPresent(Bool.self, forKey: .cooldownEnabled) ?? true
        }
    }

    struct Schedule: Codable, Identifiable, Equatable {
        var id = UUID()
        var itemIDs: Set<String>
        var startMinute: Int
        var endMinute: Int

        var duration: Int { (endMinute - startMinute + 1440) % 1440 }

        func isActive(at date: Date, calendar: Calendar = .current) -> Bool {
            let minute = calendar.component(.hour, from: date) * 60 + calendar.component(.minute, from: date)
            if startMinute < endMinute { return minute >= startMinute && minute < endMinute }
            return minute >= startMinute || minute < endMinute
        }
    }

    // Optional fields retain compatibility with previously saved pauses.
    struct Pause: Codable {
        var cooldownEnd: Date?
        var resetAt: Date?
    }

    static func resetDate(after date: Date, minutes: Int) -> Date {
        date.addingTimeInterval(Double(minutes * 60))
    }

    static func hasReset(_ pause: Pause, at now: Date) -> Bool {
        (pause.cooldownEnd ?? pause.resetAt ?? .distantPast) <= now
    }

    static func shouldResetForInactivity(lastActivity: Date?, resetMinutes: Int, at now: Date) -> Bool {
        guard let lastActivity else { return false }
        return resetDate(after: lastActivity, minutes: resetMinutes) <= now
    }

    static func blockedIDs(schedules: [Schedule], at now: Date) -> Set<String> {
        schedules.filter { $0.isActive(at: now) }.reduce(into: Set<String>()) { $0.formUnion($1.itemIDs) }
    }
}

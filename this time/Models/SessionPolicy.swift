import Foundation

enum SessionPolicy {
    // Usage thresholds are independent of the longer monitoring window.
    static let minimumMinutes = 1
    static let maximumMinutes = 240
    static let allowedMinutes = minimumMinutes...maximumMinutes
    static let minimumAnswerLength = 10

    static func isValidAnswer(_ answer: String) -> Bool {
        answer.trimmingCharacters(in: .whitespacesAndNewlines).count >= minimumAnswerLength
    }
}

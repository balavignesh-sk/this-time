import Foundation

enum SessionPolicy {
    // Usage thresholds are independent of the longer monitoring window.
    static let minimumMinutes = 1
    static let maximumMinutes = 240
    static let allowedMinutes = minimumMinutes...maximumMinutes
}

import Foundation
import UserNotifications

@MainActor
protocol SessionNotifications {
    func requestAuthorization() async
}

struct LocalSessionNotifications: SessionNotifications {
    func requestAuthorization() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }
}

final class IntentionNotificationDelegate: NSObject, UNUserNotificationCenterDelegate, Sendable {
    static let shared = IntentionNotificationDelegate()
    static let opened = Notification.Name("thisTime.reflectionOpened")

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.content.userInfo["route"] as? String == "reflection" {
            NotificationCenter.default.post(name: Self.opened, object: nil)
        }
        completionHandler()
    }
}

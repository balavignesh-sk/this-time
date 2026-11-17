import ManagedSettings
import UserNotifications

final class IntentionShieldAction: ShieldActionDelegate {
    override func handle(action: ShieldAction, for application: ApplicationToken,
                         completionHandler: @escaping (ShieldActionResponse) -> Void) {
        respond(action, application: application, completionHandler: completionHandler)
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken,
                         completionHandler: @escaping (ShieldActionResponse) -> Void) {
        respond(action, website: webDomain, completionHandler: completionHandler)
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken,
                         completionHandler: @escaping (ShieldActionResponse) -> Void) {
        respond(action, category: category, completionHandler: completionHandler)
    }

    private func respond(_ action: ShieldAction, application: ApplicationToken? = nil,
                         website: WebDomainToken? = nil, category: ActivityCategoryToken? = nil,
                         completionHandler: @escaping (ShieldActionResponse) -> Void) {
        guard action == .secondaryButtonPressed else { completionHandler(.close); return }
        do {
            try ScreenTimeShared.request(application: application, website: website, category: category)
            let content = UNMutableNotificationContent()
            content.title = String(localized: "Why do you want to use it?")
            content.body = String(localized: "Tap to answer, then decide whether to open it.")
            content.sound = .default
            content.userInfo = ["route": "setAppOpenIntention"]
            let request = UNNotificationRequest(identifier: "thisTime.setAppOpenIntention", content: content,
                                                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false))
            // Keep the shield visible while iOS presents the notification.
            UNUserNotificationCenter.current().add(request) { _ in completionHandler(.none) }
        } catch {
            completionHandler(.none)
        }
    }
}

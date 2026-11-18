import SwiftUI
import UserNotifications

@main
struct Main: App {
    init() {
        UNUserNotificationCenter.current().delegate = IntentionNotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

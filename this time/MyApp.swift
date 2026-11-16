import SwiftUI
import UserNotifications

@main
struct MyApp: App {
    init() {
        UNUserNotificationCenter.current().delegate = IntentionNotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

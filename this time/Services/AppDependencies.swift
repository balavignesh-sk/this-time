import Foundation

@MainActor
struct AppDependencies {
    var avatar: AvatarConfiguration = .promiseBoy
    var blocking: any BlockingClient
    var preferences: any AppPreferences = UserDefaultsAppPreferences()
    var notifications: any SessionNotifications = LocalSessionNotifications()

    static func live() -> AppDependencies {
        #if os(iOS) && FAMILY_CONTROLS
        AppDependencies(blocking: AppBlocking())
        #else
        AppDependencies(blocking: DisabledBlockingClient())
        #endif
    }

    func makeStore() -> IntentionStore { IntentionStore(blocking: blocking, preferences: preferences, notifications: notifications) }
}

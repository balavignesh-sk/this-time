import SwiftUI

struct MainTabs: View {
    let store: IntentionStore
    let avatar: AvatarConfiguration

    var body: some View {
        TabView {
            Tab("Rules", systemImage: "slider.horizontal.3") {
                NavigationStack { BlockedServicesView(store: store) }
            }
            Tab("Reflect", systemImage: "text.bubble") {
                NavigationStack { HistoryView(entries: store.history) }
            }
            Tab("Settings", systemImage: "gearshape") {
                NavigationStack { SettingsView(store: store) }
            }
        }
    }
}

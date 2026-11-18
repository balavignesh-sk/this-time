import SwiftUI

struct MainTabs: View {
    let store: IntentionStore
    let avatar: AvatarConfiguration

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                PromiseBoy()
                    .frame(width: 180, height: 240)
                    .accessibilityLabel("Promise Boy")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColors.background)
            }
            Tab("Rules", systemImage: "lock") {
                NavigationStack { BlockedServicesView(store: store) }
            }
            Tab("History", systemImage: "clock.arrow.circlepath") {
                NavigationStack { HistoryView(entries: store.history) }
            }
        }
    }
}

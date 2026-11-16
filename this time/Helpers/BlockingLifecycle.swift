import SwiftUI

/// Reconcile persisted shields when returning from Settings, without polling.
struct BlockingLifecycle: ViewModifier {
    let store: IntentionStore
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase, initial: true) { _, phase in
                if phase == .active { store.refreshBlocking() }
            }
            .task {
                for await _ in NotificationCenter.default.notifications(named: IntentionNotificationDelegate.opened) {
                    store.refreshBlocking()
                }
            }
    }
}


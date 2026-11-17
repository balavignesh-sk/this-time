import SwiftUI

/// Reconcile persisted shields when returning from Settings, without polling.
struct BlockingLifecycle: ViewModifier {
    let store: IntentionStore
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .task(id: scenePhase) {
                guard scenePhase == .active else { return }
                store.refreshBlocking()
                // Bounded retries give authorization time to settle after launch/resume.
                // Leaving the foreground cancels this task.
                for delay in [1, 2, 3] {
                    guard store.protectionNeedsAuthorization else { break }
                    do { try await Task.sleep(for: .seconds(delay)) }
                    catch { return }
                    guard !Task.isCancelled else { return }
                    store.refreshBlocking()
                }
            }
            .task {
                for await _ in NotificationCenter.default.notifications(named: IntentionNotificationDelegate.opened) {
                    store.refreshBlocking()
                }
            }
    }
}


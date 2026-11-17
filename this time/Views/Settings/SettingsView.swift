import SwiftUI
#if os(iOS)
import UIKit
#endif

struct SettingsView: View {
    let store: IntentionStore
    @State private var confirmClear = false
    @State private var confirmDisable = false
    @State private var busy = false

    var body: some View {
        Form {
            Section {
                if store.blockingEnabled {
                    Button("Turn off protection") { confirmDisable = true }
                }
                if !store.blockingEnabled || store.protectionNeedsAuthorization {
                    Button(busy ? "Connecting…" : store.protectionNeedsAuthorization ? "Restore Screen Time access" : "Enable protection") {
                        busy = true
                        Task {
                            await store.enableBlocking()
                            busy = false
                        }
                    }
                    .disabled(busy || !store.isBlockingAvailable)
                }
            }

            Section {
                NavigationLink("Notifications") {
                    NotificationSettingsView(store: store)
                }
                NavigationLink("Alternative activities") {
                    Form {
                        Section { AlternativesSection(store: store) }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Paper.background)
                    .navigationTitle("Alternatives")
                }
            }

            Section {
                Button("Clear history", role: .destructive) { confirmClear = true }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Paper.background)
        .navigationTitle("Settings")
        .confirmationDialog("Clear history?", isPresented: $confirmClear, titleVisibility: .visible) {
            Button("Clear history", role: .destructive) { store.clearHistory() }
        } message: {
            Text("Your saved intentions will be deleted. Your rules will stay.")
        }
        .confirmationDialog("Turn off protection?", isPresented: $confirmDisable, titleVisibility: .visible) {
            Button("Turn off", role: .destructive) { store.disableBlocking() }
        } message: {
            Text("Your selected apps and websites will be unlocked.")
        }
    }
}

private struct NotificationSettingsView: View {
    let store: IntentionStore
    @Environment(\.openURL) private var openURL

    var body: some View {
        Form {
            Section {
                Button("Enable notifications") {
                    Task { await store.requestNotifications() }
                }
                #if os(iOS)
                Button("Open notification settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                #endif
            } footer: {
                Text("Optional. You can always unlock from Rules.")
            }
        }
        .scrollContentBackground(.hidden)
        .background(Paper.background)
        .navigationTitle("Notifications")
    }
}

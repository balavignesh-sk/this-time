import SwiftUI
#if os(iOS)
import UIKit
#endif

struct SettingsView: View {
    let store: IntentionStore
    @Environment(\.openURL) private var openURL
    @State private var confirmClear = false
    @State private var confirmDisable = false
    @State private var busy = false

    var body: some View {
        Form {
            Section("Protection") {
                if store.blockingEnabled {
                    Button("Turn off protection", role: .destructive) { confirmDisable = true }
                } else {
                    Button("Enable protection") {
                        busy = true
                        Task { await store.enableBlocking(); busy = false }
                    }
                    .disabled(busy || !store.isBlockingAvailable)
                }
                Button("Allow unlock notifications") {
                    Task { await store.requestNotifications() }
                }
                #if os(iOS)
                Button("Open notification settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                }
                #endif
            }
            Section("How it works") {
                Text("1. Choose items and an unlock duration in Rules.")
                Text("2. When a shield appears, tap Tell yourself why, then open the notification.")
                Text("3. Write at least 10 characters. Read your answer and choose whether to unlock.")
                Text("4. Revisit your answers in Reflect, including times you left an item locked.")
                Text("Notifications are optional. Unlock directly from Rules whenever you need.")
                Text("App and category limits count active use. Website access uses elapsed time and unlocks all selected websites together. Screen Time may delay the automatic relock.")
                Text("Unlocking a category does not unlock apps that you also selected individually. Request an unlock for those apps separately.")
            }
            Section("Your data") {
                Text("Selections, alternatives, and answers stay on this device. There is no account, server, or analytics.")
                Button("Delete answer history", role: .destructive) { confirmClear = true }
            }
            Section("About") {
                Text("this time").font(.headline)
                Text("An app that asks why you’re opening another app.")
                if let url = URL(string: "https://github.com/anthonycaccese/are-you-sure-ios") {
                    Link("Inspired by Are you sure?", destination: url)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Paper.background)
        .navigationTitle("Settings")
        .confirmationDialog("Delete all answers?", isPresented: $confirmClear, titleVisibility: .visible) {
            Button("Delete history", role: .destructive) { store.clearHistory() }
        } message: { Text("Your rules and alternatives will be kept.") }
        .confirmationDialog("Turn off protection?", isPresented: $confirmDisable, titleVisibility: .visible) {
            Button("Turn off", role: .destructive) { store.disableBlocking() }
        } message: { Text("All selected items will be accessible until you enable protection again.") }
    }
}

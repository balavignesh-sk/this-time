import SwiftUI

struct BlockingControls: View {
    let store: IntentionStore
    @State private var enabling = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: store.blockingEnabled ? "lock.shield" : "lock.open")
                Text(store.blockingEnabled ? "Protection is on" : "Protection is off")
                Spacer()
            }
            if !store.isBlockingAvailable {
                Text("Screen Time blocking is unavailable in this build.")
                    .font(.footnote).foregroundStyle(Paper.muted)
            } else if !store.blockingEnabled {
                Button(enabling ? "Enabling…" : "Enable protection") {
                    enabling = true
                    Task {
                        await store.enableBlocking()
                        enabling = false
                    }
                }
                .buttonStyle(InkButton()).disabled(enabling)
            }
            Text("Without notifications, open Rules and tap Unlock beside an item.")
                .font(.footnote).foregroundStyle(Paper.muted)
        }
    }
}

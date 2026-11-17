import SwiftUI

struct BlockingControls: View {
    let store: IntentionStore
    @State private var enabling = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: store.blockingEnabled ? "lock.shield" : "lock.open")
                Text(store.protectionNeedsAuthorization ? "Screen Time access needed" : store.blockingEnabled ? "Protection is on" : "Protection is off")
                Spacer()
            }
            if !store.isBlockingAvailable {
                Text("Screen Time blocking is unavailable in this build.")
                    .font(.footnote).foregroundStyle(Paper.muted)
            } else if !store.blockingEnabled || store.protectionNeedsAuthorization {
                Button(enabling ? "Connecting…" : store.protectionNeedsAuthorization ? "Restore access" : "Enable protection") {
                    enabling = true
                    Task {
                        await store.enableBlocking()
                        enabling = false
                    }
                }
                .buttonStyle(InkButton()).disabled(enabling)
            }
        }
    }
}

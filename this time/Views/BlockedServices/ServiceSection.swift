import SwiftUI

struct ServiceSection: View {
    let store: IntentionStore
    let add: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Eyebrow(title: "LOCKED ITEMS")
            if store.services.isEmpty {
                Text("Choose apps, categories, or websites to pause before opening.")
                    .foregroundStyle(Paper.muted)
            }
            ForEach(store.services) { service in
                LockedServiceRow(service: service, store: store)
            }
            Button(action: add) {
                Label("Choose items to lock", systemImage: "plus")
            }
            .disabled(!store.isBlockingAvailable)
        }
    }
}

private struct LockedServiceRow: View {
    let service: Service
    let store: IntentionStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ServiceLabel(service: service)
            HStack {
                Text(store.activeSessions[service.id] != nil ? "Unlocked" : store.blockingEnabled ? "Locked" : "Protection off")
                    .font(.caption).foregroundStyle(Paper.muted)
                Spacer()
                if store.activeSessions[service.id] != nil {
                    Button("Lock now") { store.relock(service) }
                } else {
                    Button("Unlock") { store.requestUnlock(service) }
                        .disabled(!store.blockingEnabled)
                }
                Button("Remove item", systemImage: "minus.circle", role: .destructive) {
                    store.remove(service)
                }
                .labelStyle(.iconOnly)
            }
            Divider()
        }
        .padding(.vertical, 6)
    }
}

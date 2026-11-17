import SwiftUI

struct ServiceSection: View {
    let store: IntentionStore
    let showingWebsites: Bool

    var body: some View {
        ServiceGroup(
            services: store.services.filter {
                ($0.webDomainTokenData != nil) == showingWebsites
            },
            store: store
        )
    }
}

private struct ServiceGroup: View {
    let services: [Service]
    let store: IntentionStore

    var body: some View {
        Section {
            if services.isEmpty {
                Text("No items added")
                    .foregroundStyle(Paper.muted)
            }
            ForEach(services) { service in
                LockedServiceRow(service: service, store: store)
                    .swipeActions {
                        Button("Remove", role: .destructive) { store.remove(service) }
                    }
            }
        }
        .listRowBackground(Paper.background)
    }
}

private struct LockedServiceRow: View {
    let service: Service
    let store: IntentionStore

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                ServiceLabel(service: service)
                Text(store.protectionNeedsAuthorization ? "Access needed" : store.activeSessions[service.id] != nil ? "Unlocked" : store.blockingEnabled ? "Locked" : "Protection off")
                    .font(.caption)
                    .foregroundStyle(Paper.muted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if store.activeSessions[service.id] != nil {
                Button("Lock", systemImage: "lock") { store.relock(service) }
                    .buttonStyle(.borderless)
            } else {
                Button("Unlock", systemImage: "lock.open") { store.requestUnlock(service) }
                    .buttonStyle(.borderless)
                    .disabled(!store.blockingEnabled || store.protectionNeedsAuthorization)
            }
        }
        .padding(.vertical, 6)
        .contextMenu {
            Button("Remove", systemImage: "trash", role: .destructive) { store.remove(service) }
        }
    }
}

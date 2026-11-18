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
                    .foregroundStyle(AppColors.textSecondary)
            }
            ForEach(services) { service in
                LockedServiceRow(service: service, store: store)
                    .listRowInsets(EdgeInsets(top: 24, leading: 20, bottom: 24, trailing: 20))
                    .listRowSeparator(service.id == services.first?.id ? .hidden : .visible, edges: .top)
                    .listRowSeparator(service.id == services.last?.id ? .hidden : .visible, edges: .bottom)
                    .listRowSeparatorTint(AppColors.separator)
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                    .alignmentGuide(.listRowSeparatorTrailing) { dimensions in dimensions.width }
                    .swipeActions {
                        Button("Remove", role: .destructive) { store.remove(service) }
                    }
            }
        }
        .listSectionSeparator(.hidden)
        .listRowBackground(AppColors.background)
    }
}

private struct LockedServiceRow: View {
    let service: Service
    let store: IntentionStore

    var body: some View {
        HStack(spacing: 12) {
            ServiceLabel(service: service)
                .labelStyle(ServiceRowLabelStyle())
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityValue(Text(store.protectionNeedsAuthorization ? "Access needed" : store.activeSessions[service.id] != nil ? "Unlocked" : store.blockingEnabled ? "Locked" : "Protection off"))
            if store.activeSessions[service.id] != nil {
                Button("Lock", systemImage: "lock") { store.relock(service) }
                    .buttonStyle(.borderless)
            } else {
                Button("Unlock", systemImage: "lock.open") { store.requestUnlock(service) }
                    .buttonStyle(.borderless)
                    .disabled(!store.blockingEnabled || store.protectionNeedsAuthorization)
            }
        }
        .font(.subheadline)
        .fontDesign(.default)
        .contextMenu {
            Button("Remove", systemImage: "trash", role: .destructive) { store.remove(service) }
        }
    }
}

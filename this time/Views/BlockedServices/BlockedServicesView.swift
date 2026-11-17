import SwiftUI

struct BlockedServicesView: View {
    let store: IntentionStore
    @State private var showingAddService = false
    @State private var showingWebsites = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                RulesFilterPill(title: "Apps", isSelected: !showingWebsites) {
                    showingWebsites = false
                }
                RulesFilterPill(title: "Websites", isSelected: showingWebsites) {
                    showingWebsites = true
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)

            List {
                if !store.blockingEnabled || !store.isBlockingAvailable || store.protectionNeedsAuthorization {
                    Section { BlockingControls(store: store) }
                        .listRowBackground(Paper.background)
                }
                ServiceSection(store: store, showingWebsites: showingWebsites)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .background(Paper.background)
        .navigationTitle("Rules")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add apps or websites", systemImage: "plus") {
                    showingAddService = true
                }
                .disabled(!store.isBlockingAvailable)
            }
            ToolbarItem(placement: .secondaryAction) {
                NavigationLink {
                    SettingsView(store: store)
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showingAddService) { AddServiceView(store: store) }
    }
}

private struct RulesFilterPill: View {
    let title: LocalizedStringKey
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 20)
                .frame(minHeight: 44)
                .foregroundStyle(isSelected ? Paper.background : Paper.ink)
                .background(isSelected ? Paper.ink : Paper.ink.opacity(0.06), in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct UnlockDurationSection: View {
    let store: IntentionStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Eyebrow(title: "UNLOCK DURATION")
            Picker("Unlock duration", selection: Binding(
                get: { store.intention.unlockMinutes }, set: { store.setUnlockMinutes($0) }
            )) {
                Text("5 min").tag(5)
                Text("15 min").tag(15)
                Text("30 min").tag(30)
            }
            .pickerStyle(.segmented)
            Text("Apps and categories count active use. Websites unlock together for elapsed time. You can lock them again early.")
                .font(.footnote).foregroundStyle(Paper.muted)
        }
    }
}

struct AlternativesSection: View {
    let store: IntentionStore
    @State private var newActivity = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Eyebrow(title: "OTHER OPTIONS")
            Text("Anything else on the list?").font(.headline)
            Text("Optional. These may come up when we ask why you’re opening an app.")
                .font(.footnote).foregroundStyle(Paper.muted)
            ForEach(store.intention.alternatives) { activity in
                AlternativeRow(activity: activity, store: store)
            }
            HStack {
                TextField("Reading, walking, calling a friend…", text: $newActivity)
                    .onSubmit(add)
                Button("Add", systemImage: "plus", action: add)
                    .labelStyle(.iconOnly)
                    .disabled(newActivity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.vertical, 12)
            .overlay(alignment: .bottom) { Divider() }
        }
    }

    private func add() {
        store.addAlternative(newActivity)
        newActivity = ""
    }
}

private struct AlternativeRow: View {
    let activity: AlternativeActivity
    let store: IntentionStore
    @State private var editing = false
    @State private var draft = ""

    var body: some View {
        HStack {
            Button(activity.text) { draft = activity.text; editing = true }
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("Remove alternative", systemImage: "minus.circle", role: .destructive) {
                store.removeAlternative(activity)
            }.labelStyle(.iconOnly)
        }
        .alert("Edit alternative", isPresented: $editing) {
            TextField("Activity", text: $draft)
            Button("Save") { store.updateAlternative(activity, text: draft) }
            Button("Cancel", role: .cancel) {}
        }
    }
}

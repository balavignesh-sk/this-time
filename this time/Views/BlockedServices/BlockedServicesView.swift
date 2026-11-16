import SwiftUI

struct BlockedServicesView: View {
    let store: IntentionStore
    @State private var showingAddService = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                RulesIntroduction()
                BlockingControls(store: store)
                ServiceSection(store: store) { showingAddService = true }
                UnlockDurationSection(store: store)
                AlternativesSection(store: store)
            }
            .padding(24)
            .frame(maxWidth: 620)
            .frame(maxWidth: .infinity)
        }
        .background(Paper.background)
        .navigationTitle("Rules")
        .sheet(isPresented: $showingAddService) { AddServiceView(store: store) }
    }
}

private struct RulesIntroduction: View {
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Eyebrow(title: "THIS TIME")
                Text("What gets a question?").font(.title2)
                Text("Choose which apps and websites ask before opening.")
                    .font(.subheadline).foregroundStyle(Paper.muted)
            }
            Spacer(minLength: 0)
            PromiseBoy().frame(width: 76, height: 100).accessibilityHidden(true)
        }
    }
}

private struct UnlockDurationSection: View {
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

private struct AlternativesSection: View {
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

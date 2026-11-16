import SwiftUI

struct IntentionFlow: View {
    let presentation: IntentionStore.Presentation
    let store: IntentionStore
    @Environment(\.dismiss) private var dismiss
    @State private var answer = ""
    @State private var confirming = false
    @State private var steppedAway = false
    @State private var saving = false
    @State private var minutes: Int

    init(presentation: IntentionStore.Presentation, store: IntentionStore) {
        self.presentation = presentation
        self.store = store
        _minutes = State(initialValue: min(max(store.intention.unlockMinutes,
                                              SessionPolicy.minimumMinutes),
                                          SessionPolicy.maximumMinutes))
    }

    private var validAnswer: Bool {
        answer.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    ServiceLabel(service: presentation.service)
                        .foregroundStyle(Paper.muted)
                    if steppedAway {
                        PromiseBoy().frame(width: 100, height: 130).accessibilityHidden(true)
                        Text("Not opening it, then.").font(.title)
                        Text("Answer saved. Still locked.")
                            .foregroundStyle(Paper.muted)
                        Button("Done") { dismiss() }.buttonStyle(InkButton())
                    } else if confirming {
                        Eyebrow(title: "YOUR ANSWER")
                        Text("Still want to open it?").font(.largeTitle)
                        Text(answer.trimmingCharacters(in: .whitespacesAndNewlines))
                            .font(.title3)
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Paper.ink.opacity(0.05))
                        IntentionDurationPicker(minutes: $minutes)
                        Text(presentation.service.webDomainTokenData != nil
                             ? "Continuing unlocks all selected websites for \(minutes) minutes."
                             : "Continuing allows \(minutes) minutes of active use.")
                            .foregroundStyle(Paper.muted)
                        Button("Yes, unlock") { decide(unlock: true) }
                            .buttonStyle(InkButton())
                            .disabled(saving || !SessionPolicy.allowedMinutes.contains(minutes))
                        Button("No, leave it locked") { decide(unlock: false) }
                            .disabled(saving)
                    } else {
                        Eyebrow(title: "THIS TIME")
                        Text(presentation.prompt.text).font(.title2)
                        TextField("Write your reason", text: $answer, axis: .vertical)
                            .lineLimit(3...8)
                            .padding(.vertical, 16)
                            .overlay(alignment: .bottom) { Divider() }
                        Text("Write at least 10 characters.")
                            .font(.caption).foregroundStyle(Paper.muted)
                        Button("Continue") { confirming = true }
                            .buttonStyle(InkButton()).disabled(!validAnswer)
                    }
                }
                .padding(28)
                .frame(maxWidth: 540)
                .frame(maxWidth: .infinity)
            }
            .background(Paper.background)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(confirming && !steppedAway ? "Back" : "Close") {
                        if confirming && !steppedAway { confirming = false } else { dismiss() }
                    }.disabled(saving)
                }
            }
        }
        .tint(Paper.ink)
        .interactiveDismissDisabled(saving)
        .alert("Couldn’t save your answer", isPresented: Binding(
            get: { store.notice != nil },
            set: { if !$0 { store.notice = nil } }
        )) {
            Button("OK") { store.notice = nil }
        } message: { Text(store.notice ?? "") }
    }

    private func decide(unlock: Bool) {
        saving = true
        let succeeded = store.decide(requestID: presentation.id, answer: answer, unlock: unlock, minutes: minutes)
        saving = false
        if succeeded {
            if unlock { dismiss() } else { steppedAway = true }
        }
    }
}


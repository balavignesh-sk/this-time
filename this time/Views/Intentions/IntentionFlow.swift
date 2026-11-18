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
        _minutes = State(initialValue: 15)
    }

    private var validAnswer: Bool {
        SessionPolicy.isValidAnswer(answer)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    ServiceLabel(service: presentation.service)
                        .foregroundStyle(AppColors.textSecondary)
                    if steppedAway {
                        PromiseBoy().frame(width: 100, height: 130).accessibilityHidden(true)
                        Text("Not opening it, then.").font(.title)
                        Text("Answer saved. Still locked.")
                            .foregroundStyle(AppColors.textSecondary)
                        Button("Done") { dismiss() }.buttonStyle(InkButton())
                    } else if confirming {
                        Text("So, you want to open it because \"\(answer.trimmingCharacters(in: .whitespacesAndNewlines))\".").font(.title3)
//                        Text(answer.trimmingCharacters(in: .whitespacesAndNewlines))
//                            .font(.title3)
//                            .padding(20)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .background(AppColors.controlFill)
                        Text("How long do you want to use it for?").font(.title)
                        IntentionDurationPicker(minutes: $minutes)
                        Text(presentation.service.webDomainTokenData != nil
                             ? "Continuing unlocks all selected websites for \(minutes) minutes."
                             : "Continuing allows \(minutes) minutes of active use.")
                            .foregroundStyle(AppColors.textSecondary)
                        Button("Yes, unlock") { decide(unlock: true) }
                            .buttonStyle(InkButton())
                            .disabled(saving || !SessionPolicy.allowedMinutes.contains(minutes))
                        Button("No, leave it locked") { decide(unlock: false) }
                            .disabled(saving)
                    } else {
                        Text(presentation.prompt.text).font(.title2)
                        TextField("Write your reason", text: $answer, axis: .vertical)
                            .lineLimit(3...8)
                            .padding(.vertical, 16)
                            .overlay(alignment: .bottom) { Divider() }
                        Text("Write at least \(SessionPolicy.minimumAnswerLength) characters.")
                            .font(.caption).foregroundStyle(AppColors.textSecondary)
                        Button("Continue") { confirming = true }
                            .buttonStyle(InkButton()).disabled(!validAnswer)
                    }
                }
                .padding(28)
                .frame(maxWidth: 540)
                .frame(maxWidth: .infinity)
            }
            .background(AppColors.background)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(confirming && !steppedAway ? "Back" : "Close") {
                        if confirming && !steppedAway { confirming = false } else { dismiss() }
                    }.disabled(saving)
                }
            }
        }
        .tint(AppColors.accent)
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


import SwiftUI

struct OnboardingView: View {
    let store: IntentionStore
    @State private var step = 0
    @State private var busy = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                PromiseBoy().frame(width: 120, height: 152).accessibilityHidden(true)
                Eyebrow(title: "THIS TIME")
                Text(step == 0 ? "One question first." : step == 1 ? "Choose what gets blocked." : "Notifications, if you want.")
                    .font(.largeTitle)
                Text(step == 0
                     ? "Before opening an app, write why you want to use it. Then open it, or don’t."
                     : step == 1
                     ? "Screen Time lets this time shield the apps, categories, and websites you choose. Your selections and answers stay on this device."
                     : "Tap a notification to answer the question and unlock. You can also do this from Rules. Notifications are optional.")
                    .foregroundStyle(Paper.muted)
                if step == 0 {
                    Button("Get started") { step = 1 }.buttonStyle(InkButton())
                } else if step == 1 {
                    Button(busy ? "Connecting…" : "Allow Screen Time") {
                        busy = true
                        Task {
                            await store.enableBlocking()
                            busy = false
                            if store.blockingEnabled { step = 2 }
                        }
                    }
                    .buttonStyle(InkButton()).disabled(busy || !store.isBlockingAvailable)
                    Button("Set up later") { step = 2 }.disabled(busy)
                } else {
                    Button(busy ? "Requesting…" : "Enable notifications") {
                        busy = true
                        Task {
                            await store.requestNotifications()
                            busy = false
                            store.finishOnboarding()
                        }
                    }
                    .buttonStyle(InkButton()).disabled(busy)
                    Button("Continue without notifications") { store.finishOnboarding() }.disabled(busy)
                }
                Text("\(step + 1) / 3").font(.caption).foregroundStyle(Paper.muted)
            }
            .padding(28)
            .frame(maxWidth: 540)
            .frame(maxWidth: .infinity)
        }
        .background(Paper.background)
    }
}

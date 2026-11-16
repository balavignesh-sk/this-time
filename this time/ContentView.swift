import SwiftUI

struct ContentView: View {
    @State private var store: IntentionStore
    private let avatar: AvatarConfiguration

    @MainActor
    init(dependencies: AppDependencies) {
        _store = State(initialValue: dependencies.makeStore())
        avatar = dependencies.avatar
    }

    @MainActor
    init() { self.init(dependencies: .live()) }

    var body: some View {
        Group {
            if !store.intention.onboardingComplete {
                OnboardingView(store: store)
            } else if let service = store.unlockedService {
                SessionUnlockedView(service: service) { store.unlockedService = nil }
            } else {
                MainTabs(store: store, avatar: avatar)
            }
        }
        .font(.system(.body, design: .monospaced))
        .fontDesign(.monospaced)
        .background(Paper.background.ignoresSafeArea())
        .foregroundStyle(Paper.ink)
        .tint(Paper.ink)
        .preferredColorScheme(.light)
        .sheet(item: Binding(
            get: { store.intention.onboardingComplete ? store.pendingPresentation : nil },
            set: { _ in }
        )) { presentation in
            IntentionFlow(presentation: presentation, store: store)
                .fontDesign(.monospaced)
                .id(presentation.id)
                .onDisappear { store.cancelPendingIntention(requestID: presentation.id) }
        }
        .modifier(BlockingLifecycle(store: store))
        .onOpenURL { url in
            if url.scheme == "thistime" { store.refreshBlocking() }
        }
        .alert("Notice", isPresented: Binding(
            get: { store.notice != nil && store.pendingPresentation == nil },
            set: { if !$0 { store.notice = nil } }
        )) {
            Button("OK") { store.notice = nil }
        } message: { Text(store.notice ?? "") }
    }
}

#Preview { ContentView() }

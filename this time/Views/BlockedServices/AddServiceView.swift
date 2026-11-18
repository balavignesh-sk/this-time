import SwiftUI
// Enable FAMILY_CONTROLS only with a supported signing team and its entitlement.
#if os(iOS) && FAMILY_CONTROLS
import FamilyControls
import ManagedSettings
#endif

struct AddServiceView: View {
    let store: IntentionStore
    @Environment(\.dismiss) private var dismiss
    @State private var error: String?
    #if os(iOS) && FAMILY_CONTROLS
    @State private var authorized = false
    @State private var accessFailed = false
    @State private var selection = FamilyActivitySelection()
    #endif

    var body: some View {
        NavigationStack {
            Group {
                #if os(iOS) && FAMILY_CONTROLS
                if authorized {
                    FamilyActivityPicker(selection: $selection)
                } else if accessFailed {
                    VStack(spacing: 16) {
                        Text("Screen Time access is required to select apps and websites.")
                        Button("Try again") {
                            Task { await requestAccess() }
                        }
                        .buttonStyle(InkButton())
                    }
                    .padding(24)
                } else {
                    ProgressView("Requesting Screen Time access")
                }
                #else
                Text("App and website blocking is unavailable in this build.")
                    .padding(24)
                #endif
            }
            #if os(iOS)
            .background(Color(uiColor: .systemGroupedBackground))
            #else
            .background(Paper.background)
            #endif
            .navigationTitle("Apps & websites")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(uiColor: .systemGroupedBackground), for: .navigationBar)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                #if os(iOS) && FAMILY_CONTROLS
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if addSelection() { dismiss() }
                    }
                    .disabled(!authorized || (selection.applicationTokens.isEmpty && selection.webDomainTokens.isEmpty && selection.categoryTokens.isEmpty))
                }
                #endif
            }
            .alert("Couldn’t add selection", isPresented: Binding(
                get: { error != nil }, set: { if !$0 { error = nil } }
            )) {
                Button("OK") { error = nil }
            } message: {
                Text(error ?? "")
            }
            #if os(iOS) && FAMILY_CONTROLS
            .task { await requestAccess() }
            #endif
        }
        #if os(iOS)
        .presentationBackground(Color(uiColor: .systemGroupedBackground))
        #endif
        .tint(Paper.ink)
    }

    #if os(iOS) && FAMILY_CONTROLS
    private func requestAccess() async {
        error = nil
        accessFailed = false
        do {
            try await store.authorizeBlocking()
            authorized = true
        } catch {
            accessFailed = true
            self.error = String(localized: "Screen Time access could not be granted. Try again.")
        }
    }
    #endif

    #if os(iOS) && FAMILY_CONTROLS
    private func addSelection() -> Bool {
        do {
            let encoder = JSONEncoder()
            // Encode the whole selection first; do not silently save only part of it.
            var services: [Service] = []
            for token in selection.applicationTokens {
                services.append(Service(name: String(localized: "App"), symbol: "app",
                                        applicationTokenData: try encoder.encode(token)))
            }
            for token in selection.webDomainTokens {
                services.append(Service(name: String(localized: "Website"), symbol: "globe",
                                        webDomainTokenData: try encoder.encode(token)))
            }
            for token in selection.categoryTokens {
                services.append(Service(name: String(localized: "Category"), symbol: "square.grid.2x2",
                                        categoryTokenData: try encoder.encode(token)))
            }
            if !store.addSelection(services) {
                error = store.notice
                store.notice = nil
                return false
            }
            return true
        } catch {
            self.error = String(localized: "Your selection couldn’t be saved. Please try again.")
            return false
        }
    }
    #endif
}

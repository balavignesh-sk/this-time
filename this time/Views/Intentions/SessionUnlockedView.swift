import SwiftUI

struct SessionUnlockedView: View {
    let service: Service
    let close: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Image(systemName: "arrow.up.left")
                .font(.system(size: 56, weight: .light))
                .accessibilityHidden(true)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Unlocked")
                        .font(.system(.largeTitle, design: .monospaced))
                    ServiceLabel(service: service)
                        .font(.subheadline)
                    Text("Tap the iOS previous app button in the top-left corner to return.")
                        .font(.body)
                    Text("If the button isn’t visible, return using the app switcher.")
                        .font(.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .frame(maxWidth: 540, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button("Close", action: close)
                .buttonStyle(InkButton())
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.background.ignoresSafeArea())
    }
}

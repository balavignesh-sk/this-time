import SwiftUI

struct InkButton: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .monospaced))
            .padding(.horizontal, 16)
            .frame(minHeight: 48)
            .foregroundStyle(AppColors.textPrimary)
            .background(configuration.isPressed ? AppColors.controlFill : Color.clear)
            .overlay {
                Rectangle().strokeBorder(AppColors.buttonBorder, lineWidth: 1)
            }
            .opacity(isEnabled ? 1 : 0.4)
    }
}

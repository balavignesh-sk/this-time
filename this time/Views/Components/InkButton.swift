import SwiftUI

struct InkButton: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .monospaced))
            .padding(.horizontal, 16)
            .frame(minHeight: 48)
            .foregroundStyle(Paper.ink)
            .background(Paper.ink.opacity(configuration.isPressed ? 0.1 : 0))
            .overlay {
                Rectangle().strokeBorder(Paper.ink.opacity(isEnabled ? 0.6 : 0.2), lineWidth: 1)
            }
            .opacity(isEnabled ? 1 : 0.4)
    }
}

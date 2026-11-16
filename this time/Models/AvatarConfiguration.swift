import SwiftUI

struct AvatarConfiguration {
    enum Style {
        case promiseBoy
        case asset(String)
        case systemSymbol(String)
    }

    let style: Style
    let accessibilityLabel: LocalizedStringResource

    static let promiseBoy = AvatarConfiguration(style: .promiseBoy, accessibilityLabel: "Promise Boy")
}

/// Artwork is independent from animation, layout, and session state.
struct AvatarArtwork: View {
    let style: AvatarConfiguration.Style

    var body: some View {
        switch style {
        case .promiseBoy:
            PromiseBoy()
        case .asset(let name):
            Image(name).resizable().scaledToFit()
        case .systemSymbol(let name):
            Image(systemName: name).resizable().scaledToFit()
        }
    }
}

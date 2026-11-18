import SwiftUI

struct AvatarView: View {
    let configuration: AvatarConfiguration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if reduceMotion || scenePhase != .active {
                AvatarArtwork(style: configuration.style)
            } else {
                AvatarArtwork(style: configuration.style)
                    .phaseAnimator([false, true]) { content, inhaling in
                        content
                            .scaleEffect(
                                x: inhaling ? 1.018 : 1,
                                y: inhaling ? 1.035 : 1,
                                anchor: .bottom
                            )
                            .offset(y: inhaling ? -2 : 0)
                    } animation: { _ in
                        .easeInOut(duration: 3.5)
                    }
            }
        }
        .frame(width: 150, height: 190)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(configuration.accessibilityLabel))
        .accessibilityAddTraits(.isImage)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

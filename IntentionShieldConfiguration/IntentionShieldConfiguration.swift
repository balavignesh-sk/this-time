import ManagedSettings
import ManagedSettingsUI
import UIKit

final class IntentionShieldConfiguration: ShieldConfigurationDataSource {
    private func shield() -> ShieldConfiguration {
        let ink = UIColor(red: 0.18, green: 0.21, blue: 0.18, alpha: 1)
        // Shields inherit the blocked app's appearance, not our SwiftUI color scheme.
        let paper = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.12, green: 0.14, blue: 0.12, alpha: 1)
                : UIColor(red: 0.97, green: 0.96, blue: 0.93, alpha: 1)
        }
        let icon = UIImage(systemName: "pause.circle",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 48, weight: .regular))?
            .withTintColor(UIColor.systemOrange, renderingMode: .alwaysOriginal)
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: paper,
            icon: icon,
            title: .init(text: String(localized: "Why do you want to use it this time?"), color: .label),
            subtitle: .init(text: String(localized: "Tap “Tell me why”, then open the notification.\n\nNo notification? Open this time → Rules → Unlock."), color: .secondaryLabel),
            primaryButtonLabel: .init(text: String(localized: "Not now"), color: .white),
            primaryButtonBackgroundColor: ink,
            secondaryButtonLabel: .init(text: String(localized: "Tell me why"), color: .label)
        )
    }

    override func configuration(shielding application: Application) -> ShieldConfiguration { shield() }
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration { shield() }
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration { shield() }
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration { shield() }
}

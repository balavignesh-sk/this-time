import ManagedSettings
import ManagedSettingsUI
import UIKit

final class IntentionShieldConfiguration: ShieldConfigurationDataSource {
    private func shield() -> ShieldConfiguration {
        let ink = UIColor.darkGray
        let paper = UIColor.systemBackground
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

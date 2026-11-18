import ManagedSettings
import ManagedSettingsUI
import UIKit

private enum ShieldColors {
    // Keep the filled button's contrast independent of the host app's appearance.
    static let primaryButtonBackground = UIColor.darkGray
    static let primaryButtonText = UIColor.white
    static let secondaryButtonText = UIColor.label
}

final class IntentionShieldConfiguration: ShieldConfigurationDataSource {
    private func shield() -> ShieldConfiguration {
        let paper = UIColor.systemBackground
        let icon = UIImage(systemName: "pause.circle",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 48, weight: .regular))?
            .withTintColor(UIColor.systemOrange, renderingMode: .alwaysOriginal)
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: paper,
            icon: icon,
            title: .init(text: String(localized: "Why do you want to use it this time?"), color: .label),
            subtitle: .init(text: String(localized: "Tap “Set intention”, then open the notification.\n\nNo notification? Open this time → Rules → Unlock."), color: .secondaryLabel),
            primaryButtonLabel: .init(text: String(localized: "Not now"), color: ShieldColors.primaryButtonText),
            primaryButtonBackgroundColor: ShieldColors.primaryButtonBackground,
            secondaryButtonLabel: .init(text: String(localized: "Set intention"), color: ShieldColors.secondaryButtonText)
        )
    }

    override func configuration(shielding application: Application) -> ShieldConfiguration { shield() }
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration { shield() }
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration { shield() }
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration { shield() }
}

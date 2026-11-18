import SwiftUI

/// Semantic colors that follow the system appearance.
enum AppColors {
    #if os(iOS)
    static let background = Color(uiColor: .systemBackground)
    static let groupedBackground = Color(uiColor: .systemGroupedBackground)
    static let separator = Color(uiColor: .separator)
    static let controlFill = Color(uiColor: .tertiarySystemFill)
    static let textPrimary = Color(uiColor: .label)
    static let textSecondary = Color(uiColor: .secondaryLabel)
    #elseif os(macOS)
    static let background = Color(nsColor: .windowBackgroundColor)
    static let groupedBackground = Color(nsColor: .underPageBackgroundColor)
    static let separator = Color(nsColor: .separatorColor)
    static let controlFill = Color(nsColor: .controlBackgroundColor)
    static let textPrimary = Color(nsColor: .labelColor)
    static let textSecondary = Color(nsColor: .secondaryLabelColor)
    #else
    static let background = Color.black
    static let groupedBackground = Color.black
    static let separator = Color.secondary
    static let controlFill = Color.gray
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    #endif

    static let accent = textPrimary
    static let selectedControlBackground = textPrimary
    static let selectedControlForeground = background
    static let buttonBorder = separator
}


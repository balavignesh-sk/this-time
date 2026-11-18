import SwiftUI

enum Paper {
    #if os(iOS)
    static let background = Color(uiColor: .systemBackground)
    #elseif os(macOS)
    static let background = Color(nsColor: .windowBackgroundColor)
    #else
    static let background = Color.white
    #endif
    static let ink = Color.primary
    static let orange = Color.orange
    static let muted = Color.secondary
}

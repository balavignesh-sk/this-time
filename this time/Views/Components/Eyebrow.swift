import SwiftUI

struct Eyebrow: View {
    let title: LocalizedStringKey
    var body: some View {
        Text(title).font(.system(.caption2, design: .monospaced)).tracking(2)
            .foregroundStyle(Paper.muted)
    }
}

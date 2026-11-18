import SwiftUI
// Enable FAMILY_CONTROLS only with a supported signing team and its entitlement.
#if os(iOS) && FAMILY_CONTROLS
import FamilyControls
import ManagedSettings
#endif

struct ServiceLabel: View {
    let service: Service

    var body: some View {
        #if os(iOS) && FAMILY_CONTROLS
        if let data = service.applicationTokenData,
           let token = try? JSONDecoder().decode(ApplicationToken.self, from: data) {
            Label(token)
        } else if let data = service.webDomainTokenData,
                  let token = try? JSONDecoder().decode(WebDomainToken.self, from: data) {
            Label(token)
        } else if let data = service.categoryTokenData,
                  let token = try? JSONDecoder().decode(ActivityCategoryToken.self, from: data) {
            Label(token)
        } else {
            Label(service.name, systemImage: service.symbol)
        }
        #else
        Label(service.name, systemImage: service.symbol)
        #endif
    }
}

struct ServiceRowLabelStyle: LabelStyle {
    @ScaledMetric(relativeTo: .subheadline) private var iconSize = 24

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 10) {
            configuration.icon
                .frame(width: iconSize, height: iconSize)
            configuration.title
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}


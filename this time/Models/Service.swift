import Foundation

struct Service: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let domain: String
    let symbol: String
    var applicationTokenData: Data?
    var webDomainTokenData: Data?
    var categoryTokenData: Data?

    init(id: String = UUID().uuidString, name: String, domain: String = "", symbol: String,
         applicationTokenData: Data? = nil, webDomainTokenData: Data? = nil, categoryTokenData: Data? = nil) {
        self.id = id
        self.name = name
        self.domain = domain
        self.symbol = symbol
        self.applicationTokenData = applicationTokenData
        self.webDomainTokenData = webDomainTokenData
        self.categoryTokenData = categoryTokenData
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, domain, symbol, applicationTokenData, webDomainTokenData, categoryTokenData
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        domain = try values.decode(String.self, forKey: .domain)
        symbol = try values.decode(String.self, forKey: .symbol)
        applicationTokenData = try values.decodeIfPresent(Data.self, forKey: .applicationTokenData)
        webDomainTokenData = try values.decodeIfPresent(Data.self, forKey: .webDomainTokenData)
        categoryTokenData = try values.decodeIfPresent(Data.self, forKey: .categoryTokenData)
    }

    static func website(_ input: String) -> Service? {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let address = text.contains("://") ? text : "https://" + text
        guard let components = URLComponents(string: address),
              let scheme = components.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              components.user == nil, components.password == nil,
              let host = components.url?.host()?.lowercased(),
              host.count <= 253, host.contains(".") else { return nil }
        let labels = host.split(separator: ".", omittingEmptySubsequences: false)
        guard labels.allSatisfy({ label in
            !label.isEmpty && label.count <= 63 &&
            label.first != "-" && label.last != "-" &&
            label.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-") }
        }) else { return nil }
        return Service(id: "website:" + host, name: host, domain: host, symbol: "globe")
    }
}


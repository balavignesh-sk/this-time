import Foundation

struct Service: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let symbol: String
    var applicationTokenData: Data?
    var webDomainTokenData: Data?
    var categoryTokenData: Data?

    init(id: String = UUID().uuidString, name: String, symbol: String,
         applicationTokenData: Data? = nil, webDomainTokenData: Data? = nil, categoryTokenData: Data? = nil) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.applicationTokenData = applicationTokenData
        self.webDomainTokenData = webDomainTokenData
        self.categoryTokenData = categoryTokenData
    }

}

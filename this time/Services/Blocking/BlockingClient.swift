import Foundation

struct BlockingRequest {
    let id: UUID
    let itemID: String
}

@MainActor
protocol BlockingClient {
    var isAvailable: Bool { get }
    var isAuthorized: Bool { get }
    func authorize() async throws
    func apply(services: [Service], enabled: Bool) throws
    func clear() throws
    func requestUnlock(for service: Service) throws
    func activeSessions() throws -> [String: UUID]
    func pendingRequest() throws -> BlockingRequest?
    func cancelRequest(_ id: UUID?)
    func beginSession(service: Service, requestID: UUID, sessionID: UUID, minutes: Int, reason: String) throws
    func endSession(_ id: UUID)
}

/// The normal Personal Team build must never simulate successful blocking.
struct DisabledBlockingClient: BlockingClient {
    var isAvailable: Bool { false }
    var isAuthorized: Bool { false }
    func authorize() async throws { throw Unavailable() }
    func apply(services: [Service], enabled: Bool) throws {
        if enabled { throw Unavailable() }
    }
    func clear() {}
    func requestUnlock(for service: Service) throws { throw Unavailable() }
    func activeSessions() throws -> [String: UUID] { [:] }
    func pendingRequest() throws -> BlockingRequest? { nil }
    func cancelRequest(_ id: UUID?) {}
    func beginSession(service: Service, requestID: UUID, sessionID: UUID, minutes: Int, reason: String) throws {
        throw Unavailable()
    }
    func endSession(_ id: UUID) {}

    private struct Unavailable: LocalizedError {
        var errorDescription: String? {
            String(localized: "App blocking isn’t enabled in this build.")
        }
    }
}

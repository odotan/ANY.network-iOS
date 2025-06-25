import Foundation

public struct XMTPUser: Codable, Identifiable, Equatable {
    public var id: String { address }
    public let address: String
    public let inboxId: String

    public init(address: String, inboxId: String) {
        self.address = address
        self.inboxId = inboxId
    }
}


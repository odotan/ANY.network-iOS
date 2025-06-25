import Foundation

struct XMTPMessage: Codable, Identifiable, Equatable {
    var id: UUID
    let hiUPoints: Int
    let from: String
    let to: String
    let toInboxId: String
    let latestEthereumBlockNumber: Int
    let blockHash: String
    let blockUnixTime: Int
    let messageCreationStartUnixTime: Int
    let replyToAddress: String
    let salt: String
    
    var startedAt: Date {
        return Date(timeIntervalSince1970: TimeInterval(messageCreationStartUnixTime))
    }
}

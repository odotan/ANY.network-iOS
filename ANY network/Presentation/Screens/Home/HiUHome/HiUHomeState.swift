import Foundation
import XMTPiOS

extension HiUHomeViewModel {
    struct State: Equatable {
        var selectedCell: HexCell?
        var cellQueue: [OffsetCoordinate: HexFlowerModel] = [:]
        var cellQueueOrder: [OffsetCoordinate] = [] // Tracks the order of insertion
        var xmtpUsers: [XMTPUser]?
        var lastTapTime: Date?
        var lastTappedCell: HexCell?
        var xmtpClientInitialized: Bool = false
        var xmtpClientError: String?
        
        // XMTP Conversation State
        var conversations: [Conversation] = []
        var messages: [DecodedMessage] = []
        var conversationError: String?
        var messageError: String?
    }
    
    enum Event {
        case stateUpdated(HexFlowerState, HexCell)
        case details(HexCell)
        case moveBack
        case recenter
        case setCellState(OffsetCoordinate, HexFlowerModel)
        case updateLastTap(time: Date?, cell: HexCell?)
        case initializeXMTP
        case testClearAndInitialize
        
        // XMTP Conversation Events
        case listConversations
        case startConversationStream
        case startMessageStream
        case stopStreams
        case sendMessage(inboxId: String, content: [String: String])
        
        case storeXMTPUser(user: XMTPUser)
        case fetchAllXMTPUsers
    }
}

extension DecodedMessage: @retroactive Equatable {
    public static func == (lhs: DecodedMessage, rhs: DecodedMessage) -> Bool {
        lhs.id == rhs.id
    }
}

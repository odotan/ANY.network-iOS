import Foundation

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
        var clientAddress: String?
        
        // XMTP Conversation State
        var messages: [XMTPMessage] = []
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
        
        // XMTP Conversation Events
        case listConversations
        case startConversationStream
        case startMessageStream
        case stopStreams
        case sendMessage(XMTPUser)
        
        case storeXMTPUser(user: XMTPUser)
        case fetchAllXMTPUsers
    }
}

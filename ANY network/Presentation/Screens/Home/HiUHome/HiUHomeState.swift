import Foundation

extension HiUHomeViewModel {
    struct State: Equatable {
        var selectedCell: HexCell?
        var cellQueue: [OffsetCoordinate: HexFlowerModel] = [:]
        var cellQueueOrder: [OffsetCoordinate] = [] // Tracks the order of insertion
        var lastTapTime: Date?
        var lastTappedCell: HexCell?
        var xmtpClientInitialized: Bool = false
        var xmtpClientError: String?
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
    }
}

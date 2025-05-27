import Foundation

extension HiUHomeViewModel {
    struct State: Equatable {
        var selectedCell: HexCell?
        var cellQueue: [OffsetCoordinate: HexFlowerModel] = [:]
        var cellQueueOrder: [OffsetCoordinate] = [] // Tracks the order of insertion
    }
    
    enum Event {
        case stateUpdated(HexFlowerState, HexCell)
        case doubleTap(HexCell)
        case details(HexCell)
        case moveBack
        case recenter
        case startTimer
    }
}

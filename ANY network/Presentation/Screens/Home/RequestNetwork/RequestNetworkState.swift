import Foundation

extension RequestNetworkViewModel {
    struct State: Equatable {
        var gridItems: [HexCell] = HexCell.all
        var selectedCell: HexCell?
        var contact: Contact
        var points: Int = 1
    }
    
    enum Event {
        case goBack
        case recenter
        case select(HexCell)
        case moveBack
        case pointsUpdated(Int)
    }
}

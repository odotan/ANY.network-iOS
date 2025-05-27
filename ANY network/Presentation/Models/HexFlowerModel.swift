import SwiftUI

// Import HexCell from the Common Components
import ANY_network

enum HexFlowerState {
    case initial
    case selected
    case animationStarted
    case timerStarted
}

struct HexFlowerModel: Identifiable, Equatable {
    var id: Int { cell.offsetCoordinate.hashValue }
    var cell: HexCell
    var title: String
    var startedAt: Date?
    var state: HexFlowerState = .initial
    var seconds: Int = 0
    
    init(cell: HexCell, title: String = "", startedAt: Date? = nil, state: HexFlowerState = .initial, seconds: Int = 0) {
        self.cell = cell
        self.title = title
        self.startedAt = startedAt
        self.state = state
        self.seconds = seconds
    }
    
    static func == (lhs: HexFlowerModel, rhs: HexFlowerModel) -> Bool {
        lhs.id == rhs.id
    }
} 
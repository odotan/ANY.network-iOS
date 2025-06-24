import SwiftUI

enum HexFlowerState {
    case initial
    case selected
    case animationStarted
    case timerStarted
    case finished
}

struct HexFlowerModel: Equatable {
    var address: String
    var startedAt: Date?
    var state: HexFlowerState = .initial
    
    init(address: String = "", startedAt: Date? = nil, state: HexFlowerState = .initial) {
        self.address = address
        self.startedAt = startedAt
        self.state = state
    }
}

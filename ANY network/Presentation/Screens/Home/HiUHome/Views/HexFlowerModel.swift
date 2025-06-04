import SwiftUI

enum HexFlowerState {
    case initial
    case selected
    case animationStarted
    case timerStarted
    case finished
}

struct HexFlowerModel: Equatable {
    var title: String
    var startedAt: Date?
    var state: HexFlowerState = .initial
    var seconds: Int = 0
    
    init(title: String = "", startedAt: Date? = nil, state: HexFlowerState = .initial, seconds: Int = 0) {
        self.title = title
        self.startedAt = startedAt
        self.state = state
        self.seconds = seconds
    }
}

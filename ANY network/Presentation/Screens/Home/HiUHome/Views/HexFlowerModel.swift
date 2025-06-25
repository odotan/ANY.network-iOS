import SwiftUI

enum HexFlowerState {
    case initial
    case selected
    case animationStarted
    case timerStarted
    case finished
}

struct HexFlowerModel: Equatable {
    var user: XMTPUser
    var message: XMTPMessage?
    var state: HexFlowerState = .initial
    var isLastMe: Bool = false
    
    init(user: XMTPUser, message: XMTPMessage? = nil, state: HexFlowerState = .initial, isLastMe: Bool = false) {
        self.user = user
        self.message = message
        self.state = state
        self.isLastMe = isLastMe
    }
    
    static func == (lhs: HexFlowerModel, rhs: HexFlowerModel) -> Bool {
        return lhs.user == rhs.user &&
               lhs.message?.id == rhs.message?.id &&
               lhs.message?.messageCreationStartUnixTime == rhs.message?.messageCreationStartUnixTime &&
               lhs.state == rhs.state &&
               lhs.isLastMe == rhs.isLastMe
    }
}

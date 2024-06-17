import Foundation

extension ContactsPermissionViewModel {
    enum State {
        case idle
    }
    
    enum Event {
        case allow
        case skip
        case goBack
    }
}

import Foundation

extension HomeViewModel {
    enum State {
        case idle
    }
    
    enum Event {
        case goToProfile
        case getAllContacts
    }
}

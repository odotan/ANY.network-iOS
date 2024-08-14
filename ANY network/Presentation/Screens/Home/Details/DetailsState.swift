import Foundation

extension DetailsViewModel {
    struct State: Equatable {
        var contact: Contact
        var isFavorite: Bool = false
        
        init(contact: Contact) {
            self.contact = contact
        }
    }
    
    enum Event {
        case goBack
        case checkIfFavorite
        case starPressed
    }
}

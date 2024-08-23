import Foundation

extension DetailsViewModel {
    struct State: Equatable {
        var contact: Contact
        var isFavorite: Bool = false
        var actionPrompt: ActionPrompt? = nil
        
        init(contact: Contact) {
            self.contact = contact
        }
    }
    
    enum Event {
        case goBack
        case checkIfFavorite
        case starPressed
        case performAction(Action)
        case presentPrompt(ActionPrompt?)
    }
    
    enum Action {
        case phone
    }
    
    struct ActionPrompt: Equatable {
        var id: String { title }
        let title: String
        let description: String
        let action: (() -> Void)
        
        static func == (lhs: DetailsViewModel.ActionPrompt, rhs: DetailsViewModel.ActionPrompt) -> Bool {
            lhs.id == rhs.id
        }
    }
}

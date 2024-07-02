import Foundation

extension HomeViewModel {
    struct State: Equatable {
        var searchTerm: String = ""
        var searched: [Contact]?
        
        var showSearch: Bool {
            return !searchTerm.isEmpty && searched != nil && !searched!.isEmpty
        }
    }
    
    enum Event {
        case goToProfile
        case getAllContacts
        case filterPressed
        case addFavoritePressed
        case searchUpdated(term: String)
        case searchPressed
    }
}

import Foundation

extension HomeViewModel {
    struct State: Equatable {
        var searchTerm: String = ""
        var isSheetPresented: Bool = false
        var list: [Contact]?
        var favorites: [Contact]?
        var usage: [Usage]?

        var showFavorite: Bool {
            favorites != nil && !favorites!.isEmpty
        }
        var showRecent: Bool {
            usage != nil
        }
        var showAll: Bool {
            list != nil
        }
    }
    
    enum Event {
        case goToProfile
        case getAllContacts
        case getFavoriteContacts
        case goToDetails(contact: Contact)
        case goToSearch
        case filterPressed
        case addFavoritePressed
//        case searchUpdated(term: String)
//        case searchPressed
        case sheetPresentationUpdated(to: Bool)
    }
}

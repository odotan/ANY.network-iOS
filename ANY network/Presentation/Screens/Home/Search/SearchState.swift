import Foundation

extension SearchViewModel {
    struct State: Equatable {
        var searchTerm: String = ""
        var list: [Contact] = [Contact]()
    }
    
    enum Event {
        case getAll
        case updateSearchTerm(String)
        case goBack
        case goToDetails(contact: Contact)
        case addContact
    }
}

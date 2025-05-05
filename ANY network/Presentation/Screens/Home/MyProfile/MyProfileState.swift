import Foundation

extension MyProfileViewModel {
    struct State: Equatable {
        var searchTerm: String = ""
        var isSearching: Bool = true//false
        var list: [Contact] = [Contact]()
        var selected: Contact?
        var isAlertPresented: Bool = false
    }
    
    enum Event {
        case getAll
        case updateSearchTerm(String)
        case goBack
        case setIsSearching(Bool)
        case setIsAlertPresented(Bool)
        case setContactConfirmation
        case select(Contact?)
        case setDismiss
    }
}

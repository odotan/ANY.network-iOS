import Foundation

extension ConnectNetworkConfirmationViewModel {
    struct State: Equatable {
        let networkItem: NetworkItem
        var isPublic: Bool = true
        var isSearchable: Bool = false
    }
    
    enum Event {
        case goBack
        case setIsSearchable(Bool)
        case setIsPublic(Bool)
        case connect
    }
}

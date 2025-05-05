import Foundation

extension ConnectViewModel {
    struct State: Equatable {
        let contact: Contact
        var gridItems: [HexCell] = HexCell.all
        var availableNetworks: [NetworkItem] = [.facebook, .telegram, .phone, .email]
    }
    
    enum Event {
        case goBack
        case networkSelected(NetworkItem)
        case recenter
    }
}

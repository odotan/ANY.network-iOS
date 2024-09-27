import Foundation
import SwiftUI

extension HomeViewModel {
    struct UIState: Equatable {
        // Header
        var headerSize: CGSize = .zero
        
        // Sizes
        var sheetSize: CGSize = .zero
        var gridContainerSize: CGSize = .zero
        
        // Grid
        var gridZoomScale: CGFloat = 1
        var gridContentOffset: CGPoint = .zero
        var gridContentSize: CGSize = .zero
        var gridCenterPosition: CGPoint = .zero
        var gridUserInteracting: Bool = false
        
        var contentIdentifier = UUID()
        
        // Drawer
        var drawerIsOpen: Bool = false
    }

    struct State: Equatable {
        var contactsStatus: ContactServiceType = .notDetermined
        var isSearching: Bool = false
        var list: [Contact]?
        var searchResults: [Contact]?
        var favorites: [Contact]?
        var searchedTerm: String = ""
        var gridItems: [HexCell] = HexCell.middle
        var usage: [Usage]?
        var detent: PresentationDetent = .fraction(0.5)
        var showFavorite: Bool {
            favorites != nil && !favorites!.isEmpty
        }
        var showRecent: Bool {
            usage != nil
        }
        var showAll: Bool {
            list != nil
        }
        var onboardingFinished: Bool {
            contactsStatus != .notDetermined
        }
        var gridItemsToDisplay: [HexCell] {
            if onboardingFinished {
                return gridItems
            }
            return HexCell.all
        }
        var listToDisplay: [Contact] {
            if isSearching && searchResults != nil && !searchedTerm.isEmpty {
                return searchResults ?? [Contact]()
            }
            return list ?? [Contact]()
        }
    }
    
    enum Event {
        case checkContactsStatus
        case requestAccess
        case continueRealm
        case goToProfile
        case getAllContacts
        case getFavoriteContacts
        case goToDetails(contact: Contact)
        case goToSearch
        case searchTerm(String)
        case isSearching(Bool)
        case recenter(Bool)
        case headerSize(CGSize)
        case filterPressed
        case addFavoritePressed
        case setSheetSize(CGSize)
        case setGridContainerSize(CGSize)
        case setGridZoomScale(CGFloat)
        case setGridContentOffset(CGPoint)
        case setGridContentSize(CGSize)
        case setDetent(PresentationDetent)
        case setContentIdentifier
        case setCenterPosition(CGPoint)
        case setDrawerOpen(Bool)
        case addContact
        case gridUserInteracting(Bool)
    }
}

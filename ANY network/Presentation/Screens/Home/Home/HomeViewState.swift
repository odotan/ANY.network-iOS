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
        var isEditing: Bool = false
        var isDraggingAHexagon: Bool = false
        var didDropDraggedHexagon: Bool = false
        
        var contentIdentifier = UUID()
        
        // Drawer
        var drawerIsOpen: Bool = false
        
        let onboardingProfilePicture = UIImage(named: "avatar")?.pngData()
        var isInFullscreen: Bool = false
    }

    struct State: Equatable {
        var contactsStatus: ContactServiceType = .notDetermined
        var isSearching: Bool = false
        var isMe: Contact?
        var list: [Contact]?
        var searchResults: [Contact]?
        var favorites: [Contact]?
        var searchedTerm: String = ""
        var gridItems: [HexCell] = HexCell.all
        var usage: [Usage]?
        var detent: PresentationDetent = .fraction(0.5)
        var interactions: [ContactInteraction] = []
        var cellToGet: Int?
        
        var shouldAskRealmMerge: Bool = false
        var showSettingsAlert: Bool = false

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
            return gridItems
        }
        var listToDisplay: [Contact] {
            if isSearching && searchResults != nil && !searchedTerm.isEmpty {
                return searchResults ?? [Contact]()
            }
            return list ?? [Contact]()
        }
    }
    
    enum Event {
        // MARK: Contacts
        case checkContactsStatus
        case requestAccess
        case continueRealm
        case goToProfile
        case getAllContacts
        case getFavoriteContacts
        case goToDetails(contact: Contact, point: CGPoint?)
        case addFavoritePressed
        case addContact
        case askForRealmMerge(Bool)
        case showSettingsAlert(Bool)
        case mergeRealmContacts
        case openSettingsApp

        // MARK: Search
        case goToSearch
        case searchTerm(String)
        case isSearching(Bool)
        case filterPressed

        // MARK: UI
        case recenter(Bool)
        case headerSize(CGSize)
        case setSheetSize(CGSize)
        case setGridContainerSize(CGSize)
        case setGridZoomScale(CGFloat)
        case setGridContentOffset(CGPoint)
        case setGridContentSize(CGSize)
        case setDetent(PresentationDetent)
        case setContentIdentifier
        case setCenterPosition(CGPoint)
        case setDrawerOpen(Bool)
        case setIsEditing(Bool)
        case isDraggingAHexagon(Bool)
        case didDropDraggedHexagon(Bool)
        case targetHexagon(HexCell?)
        case toggleFullscreen
        case setCellToGet(Int?)
        // This is different from `setGridContentOffset` since it moves the offset relative to the current grid offset and screen size
        case goToOffset(CGPoint, CGRect)
        case swapHexagons(Int?, Int?)

        // MARK: Interactions
        case fetchInteractions
        case interact(ContactInteraction, InteractionActionType)
        case moveInteraction(id: String, toPriority: Int?)

        // MARK: ContactActions
        case perform(ContactInteraction)
        case deleteInteraction(String)
    }
}

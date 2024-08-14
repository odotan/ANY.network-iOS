import Foundation
import SwiftUI

extension HomeViewModel {
    struct UIState: Equatable {
        // Sizes
        var sheetSize: CGSize = .zero
        var gridContainerSize: CGSize = .zero
        
        // Grid
        var gridZoomScale: CGFloat = 1
        var gridContentOffset: CGPoint = .zero
        var gridContentSize: CGSize = .zero
    }

    struct State: Equatable {
        var isSheetPresented: Bool = false
        var list: [Contact]?
        var favorites: [Contact]?
        var gridItems: [HexCell] = HexCell.inline
        var usage: [Usage]?
        var detent: PresentationDetent = .top

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
        case recenter
        case filterPressed
        case addFavoritePressed
        case sheetPresentationUpdated(to: Bool)
        case setSheetSize(CGSize)
        case setGridContainerSize(CGSize)
        case setGridZoomScale(CGFloat)
        case setGridContentOffset(CGPoint)
        case setGridContentSize(CGSize)
        case setDetent(PresentationDetent)
    }
}

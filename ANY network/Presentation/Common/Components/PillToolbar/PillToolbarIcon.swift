import SwiftUI

enum PillToolbarIcon {
    case add
    case message
    case favorite
    case search
    case back
    case foreward
    case recenter
    case custom(ImageResource)
    case customText(String)
    
    var imageName: ImageResource? {
        switch self {
        case .add:
            .plusIcon
        case .message:
            .messageIcon
        case .favorite:
            .favoriteIcon
        case .search:
            .searchIcon
        case .back:
            .arrowLeft
        case .foreward:
            .arrowRight
        case .recenter:
            .recenterIcon
        case .custom(let image):
            image
        case .customText:
            nil
        }
    }
    
    @MainActor
    var iconSize: CGSize {
        switch self {
        case .add:
            CGSize(width: <->19, height: |19)
        case .message:
            CGSize(width: <->20.5, height: |21.68)
        case .favorite:
            CGSize(width: <->21, height: |21)
        case .customText:
            .zero
        default:
            CGSize(width: <->21, height: |21)
        }
    }
}

enum PillToolbarPosition {
    case leading
    case trailing
    case middle
}

import Foundation

struct AvatarIconManager {
    var currentAvatarSet: [AvatarIcon]

    func getOffsetCoordinate(of avatar: AvatarIcon) -> OffsetCoordinate? {
        let coordinateString = avatar.iconString.drop(while: { !$0.isNumber })
        let coordinates = coordinateString.components(separatedBy: "x")
        guard coordinates.count == 2,
              let row = Int(coordinates.first!),
              let col = Int(coordinates.last!) else { return nil }
        return OffsetCoordinate(row: row, col: col)
    }
}

extension AvatarIconManager {
    static let introMyAvatar: [AvatarIcon] = [.init(iconString: "avatar4x2", backgroundColor: .appPurple)]

    static let introFirstSetOfAvatars: [AvatarIcon] = [
        .init(iconString: "avatar4x2", backgroundColor: .appPurple),
        .init(iconString: "avatar2x4", backgroundColor: .init(hex: "FF6B6B") ?? .white),
        .init(iconString: "avatar3x2", backgroundColor: .init(hex: "ADF2E6") ?? .white),
        .init(iconString: "avatar5x3", backgroundColor: .init(hex: "8DEF9D") ?? .white),
        .init(iconString: "avatar7x0", backgroundColor: .init(hex: "21AA47") ?? .white),
        .init(iconString: "avatar7x4", backgroundColor: .init(hex: "8481FE") ?? .white),
        .init(iconString: "avatar8x1", backgroundColor: .init(hex: "F2EBAD") ?? .white)
    ]

    static let introSecondSetOfAvatars: [AvatarIcon] = [
        .init(iconString: "avatar4x2", backgroundColor: .appPurple),
        .init(iconString: "avatar1x1", backgroundColor: .init(hex: "388AD1") ?? .white),
        .init(iconString: "avatar1x3", backgroundColor: .init(hex: "F2EBAD") ?? .white),

        .init(iconString: "avatar2x1", backgroundColor: .init(hex: "F2ADAD") ?? .white),
        .init(iconString: "avatar2x4", backgroundColor: .init(hex: "FF6B6B") ?? .white),

        .init(iconString: "avatar3x2", backgroundColor: .init(hex: "ADF2E6") ?? .white),
        .init(iconString: "avatar3x3", backgroundColor: .init(hex: "F2EBAD") ?? .white),
        .init(iconString: "avatar3x4", backgroundColor: .init(hex: "D8A033") ?? .white),

        .init(iconString: "avatar4x1", backgroundColor: .init(hex: "97B6F2") ?? .white),

        .init(iconString: "avatar5x3", backgroundColor: .init(hex: "8DEF9D") ?? .white),

        .init(iconString: "avatar6x0", backgroundColor: .init(hex: "97B6F2") ?? .white),
        .init(iconString: "avatar6x2", backgroundColor: .init(hex: "97B6F2") ?? .white),
        .init(iconString: "avatar6x3", backgroundColor: .init(hex: "D8A033") ?? .white),

        .init(iconString: "avatar7x0", backgroundColor: .init(hex: "21AA47") ?? .white),
        .init(iconString: "avatar7x4", backgroundColor: .init(hex: "8481FE") ?? .white),

        .init(iconString: "avatar8x1", backgroundColor: .init(hex: "F2EBAD") ?? .white),
        .init(iconString: "avatar8x3", backgroundColor: .init(hex: "7CD0FF") ?? .white),

        .init(iconString: "avatar9x2", backgroundColor: .init(hex: "E8ADF2") ?? .white)
    ]

    static var introThirdSetOfAvatars: [AvatarIcon] = [
        .init(iconString: "avatar4x2", backgroundColor: .appPurple),
        .init(iconString: "avatar1x1", backgroundColor: .init(hex: "388AD1") ?? .white),
        .init(iconString: "avatar1x3", backgroundColor: .init(hex: "F2EBAD") ?? .white),

        .init(iconString: "avatar2x1", backgroundColor: .init(hex: "F2ADAD") ?? .white),
        .init(iconString: "avatar2x2", backgroundColor: .init(hex: "FD95FF") ?? .white),
        .init(iconString: "avatar2x3", backgroundColor: .white),
        .init(iconString: "avatar2x4", backgroundColor: .init(hex: "FF6B6B") ?? .white),

        .init(iconString: "avatar3x2", backgroundColor: .init(hex: "ADF2E6") ?? .white),
        .init(iconString: "avatar3x3", backgroundColor: .init(hex: "F2EBAD") ?? .white),
        .init(iconString: "avatar3x4", backgroundColor: .init(hex: "D8A033") ?? .white),

        .init(iconString: "avatar4x1", backgroundColor: .init(hex: "97B6F2") ?? .white),
        .init(iconString: "avatar4x3", backgroundColor: .init(hex: "7CD0FF") ?? .white),

        .init(iconString: "avatar5x3", backgroundColor: .init(hex: "8DEF9D") ?? .white),
        .init(iconString: "avatar5x4", backgroundColor: .init(hex: "F87D90") ?? .white),

        .init(iconString: "avatar6x0", backgroundColor: .init(hex: "97B6F2") ?? .white),
        .init(iconString: "avatar6x1", backgroundColor: .init(hex: "F2EBAD") ?? .white),
        .init(iconString: "avatar6x2", backgroundColor: .init(hex: "97B6F2") ?? .white),
        .init(iconString: "avatar6x3", backgroundColor: .init(hex: "D8A033") ?? .white),

        .init(iconString: "avatar7x0", backgroundColor: .init(hex: "21AA47") ?? .white),
        .init(iconString: "avatar7x2", backgroundColor: .init(hex: "ADF2E6") ?? .white),
        .init(iconString: "avatar7x3", backgroundColor: .init(hex: "FF9DF5") ?? .white),
        .init(iconString: "avatar7x4", backgroundColor: .init(hex: "8481FE") ?? .white),

        .init(iconString: "avatar8x1", backgroundColor: .init(hex: "F2EBAD") ?? .white),
        .init(iconString: "avatar8x3", backgroundColor: .init(hex: "7CD0FF") ?? .white),

        .init(iconString: "avatar9x2", backgroundColor: .init(hex: "E8ADF2") ?? .white)
    ]

    static let introContactMethods: [AvatarIcon] = [
        .init(iconString: "facebook-icon", position: .init(row: 3, col: 2), backgroundColor: .appFacebookBlue),
        .init(iconString: "blackberry-messenger-icon", position: .init(row: 3, col: 3), backgroundColor: .appPink),
        .init(iconString: "twitter-icon", position: .init(row: 4, col: 1), backgroundColor: .appLightBlue),
        .init(iconString: "instagram-icon", position: .init(row: 4, col: 3), backgroundColor: .appOrange),
        .init(iconString: "phone-white-icon", position: .init(row: 5, col: 2), backgroundColor: .appGreen),
        .init(iconString: "email-white-icon", position: .init(row: 5, col: 3), backgroundColor: .appYellow),
        .init(iconString: "flower-nav", position: .init(row: 6, col: 2), backgroundColor: .appDarkGray),
        .init(iconString: "telegram-icon", position: .init(row: 7, col: 2), backgroundColor: .appDarkBlue),
        .init(iconString: "whatsapp-white-icon", position: .init(row: 7, col: 3), backgroundColor: .appGreen),
    ]
}

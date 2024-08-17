import SwiftUI

struct AvatarIcon {
    let iconString: String
    let position: OffsetCoordinate?
    let backgroundColor: Color
    var icon: Image { Image(iconString) }

    #warning("Added random color init for convenience, remove when colors are set")
    init(iconString: String, position: OffsetCoordinate? = nil, backgroundColor: Color = Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))) {
        self.iconString = iconString
        self.position = position
        self.backgroundColor = backgroundColor
    }
}

extension AvatarIcon: Equatable { }

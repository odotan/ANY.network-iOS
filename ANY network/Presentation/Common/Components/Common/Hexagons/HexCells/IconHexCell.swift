import SwiftUI

struct IconHexCell: View {
    var type: `Type`
    var pressed: (() -> Void)

    var body: some View {
        Button(action: pressed) {
            type.color
                .overlay(
                    Image(type.image)
                        .renderingMode(.template)
                        .colorMultiply(.white)
                )
        }.buttonStyle(.plain)
    }
}

#Preview {
    IconHexCell(type: .phone) { }
}

extension IconHexCell {
    enum `Type` {
        case edit // temp
        case plus
        case phone
        case email

        var image: ImageResource {
            switch self {
            case .edit:
                return .penEditIcon
            case .plus:
                return .plusIcon
            case .phone:
                return .phoneGreenIcon
            case .email:
                return .emailWhiteIcon
            }
        }
        
        var color: Color {
            switch self {
            case .edit:
                return .appPurple
            case .plus:
                return Color(hex: "302C3D") ?? .clear
            case .phone:
                return .appGreen
            case .email:
                return .appYellow
            }
        }
    }

}

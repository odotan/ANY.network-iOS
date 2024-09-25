import SwiftUI

struct IconHexCell: View {
    var type: `Type`
    var imageSize: CGSize = CGSize(width: 28, height: 28)
    var pressed: (() -> Void)

    var body: some View {
        Button(action: pressed) {
            type.color
                .overlay(
                    Image(type.image)
                        .resizable()
                        .renderingMode(.template)
                        .colorMultiply(.white)
                        .frame(width: imageSize.width, height: imageSize.height)
                        .scaledToFit()
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
        case favorite(filled: Bool)

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
            case .favorite(let filled):
                return filled ? .startFillIcon : .starIcon
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
            case .favorite(_):
                return .appYellow
            }
        }
    }

}

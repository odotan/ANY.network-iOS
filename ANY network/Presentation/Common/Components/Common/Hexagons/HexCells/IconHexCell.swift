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
        case plus
        case phone
        
        var image: ImageResource {
            switch self {
            case .plus:
                return .plusIcon
            case .phone:
                return .phoneGreenIcon
            }
        }
        
        var color: Color {
            switch self {
            case .plus:
                return Color(hex: "302C3D") ?? .clear
            case .phone:
                return Color(.appGreen)
            }
        }
    }

}

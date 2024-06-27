import SwiftUI

struct RegularHexagonButton: View {
    private let width: CGFloat
    private let cornerRadius: CGFloat
    private let borderSize: CGFloat
    private let borderColor: Color
    private let color: Color
    private let action: () -> Void
    
    init(
        width: CGFloat,
        cornerRadius: CGFloat = 3,
        borderSize: CGFloat = 0,
        borderColor: Color = .clear,
        color: Color,
        action: @escaping () -> Void
    ) {
        self.width = width
        self.cornerRadius = cornerRadius
        self.borderSize = borderSize
        self.borderColor = borderColor
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action, label: {
            Color.clear
                .clipShape(HexagonShape(cornerRadius: cornerRadius))
                .frame(width: width, height: width * 9 / 8)
                .overlay {
                    HexagonShape(cornerRadius: cornerRadius)
                        .fill(color)
                        .stroke(borderColor, style: .init(lineWidth: borderSize))
                }
        })
    }
}

#Preview {
    VStack {
        RegularHexagonButton(
            width: 160,
            cornerRadius: 10,
            color: .appPurple,
            action: {}
        )

        RegularHexagonButton(
            width: 160,
            cornerRadius: 10,
            borderSize: 4,
            borderColor: Color.appGray,
            color: .appGray.opacity(0.3),
            action: {}
        )
        
        RegularHexagonButton(
            width: 160,
            cornerRadius: 10,
            borderSize: 4,
            borderColor: Color.appGray,
            color: .appGray.opacity(0.3),
            action: {}
        )
    }
}

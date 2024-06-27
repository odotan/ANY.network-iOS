import SwiftUI

fileprivate struct ModifierCornerRadiusWithBorder: ViewModifier {
    var radius: CGFloat
    var borderLineWidth: CGFloat = 1
    var borderColor: Color = .gray
//    var cornerRadii: RectangleCornerRadii?
    
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .stroke(borderColor, lineWidth: borderLineWidth)
            }
    }
}

fileprivate struct ModifierCornerRadiiWithBorder: ViewModifier {
    var cornerRadii: RectangleCornerRadii
    var borderLineWidth: CGFloat = 1
    var borderColor: Color = .gray
    
    func body(content: Content) -> some View {
        content
            .clipShape(UnevenRoundedRectangle(cornerRadii: cornerRadii))
            .overlay {
                UnevenRoundedRectangle(cornerRadii: cornerRadii)
                    .stroke(borderColor, lineWidth: borderLineWidth)
            }
    }
}

extension View {
    func cornerRadiusWithBorder(
        radius: CGFloat,
        borderLineWidth: CGFloat = 1,
        borderColor: Color
    ) -> some View {
        modifier(
            ModifierCornerRadiusWithBorder(
                radius: radius,
                borderLineWidth: borderLineWidth,
                borderColor: borderColor
            )
        )
    }
    
    func cornerRadiusWithBorder(
        cornerRadii: RectangleCornerRadii = RectangleCornerRadii(),
        borderLineWidth: CGFloat = 1,
        borderColor: Color
    ) -> some View {
        modifier(
            ModifierCornerRadiiWithBorder(
                cornerRadii: cornerRadii,
                borderLineWidth: borderLineWidth,
                borderColor: borderColor
            )
        )
    }
}

#Preview {
    VStack {
        Color.red
            .cornerRadiusWithBorder(radius: 35, borderLineWidth: 3, borderColor: .black)
        
        Color.blue
            .cornerRadiusWithBorder(cornerRadii: .init(topLeading: 35, topTrailing: 35), borderLineWidth: 3, borderColor: .black)
    }.padding()
}

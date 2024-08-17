import SwiftUI

struct ClipShapeShadowModifier<ContentShape: Shape>: ViewModifier {
    private let hasShadow: Bool
    private let color: Color
    private let radius: CGFloat
    private let x: CGFloat
    private let y: CGFloat
    private let shape: ContentShape
    
    init(shape: ContentShape, hasShadow: Bool = false, color: Color = .black.opacity(0.25), radius: CGFloat = 4, x: CGFloat = 0, y: CGFloat = 4) {
        self.shape = shape
        self.hasShadow = hasShadow
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
    
    func body(content: Content) -> some View {
        if hasShadow {
            content
                .clipShape(shape)
                .shadow(color: color, radius: radius, x: x, y: y)
                .reverseMask({ Color.white.clipShape(shape) })
                .overlay { content.clipShape(shape) }
        } else {
            content
                .clipShape(shape)
        }
    }
}

extension View {
    @inlinable func reverseMask<Mask: View>(alignment: Alignment = .center, @ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask(
            ZStack {
                Rectangle()
                
                mask()
                    .blendMode(.destinationOut)
            }
        )
    }
    
    func clipWithShadow<ContentShape: Shape>(
        shape: ContentShape,
        hasShadow: Bool = false,
        color: Color = .black.opacity(0.25),
        radius: CGFloat = 4,
        x: CGFloat = 0,
        y: CGFloat = 4
    ) -> some View {
        self.modifier(ClipShapeShadowModifier(shape: shape, hasShadow: hasShadow, color: color, radius: radius, x: x, y: y))
    }
}

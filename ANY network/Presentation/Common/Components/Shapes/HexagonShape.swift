import SwiftUI

public struct HexagonShape: Shape {
    public static let aspectRatio: CGFloat = sqrt(3) / 2
    private let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topCenter = CGPoint(x: rect.midX, y: rect.minY)
        let topLeft = CGPoint(x: rect.minX, y: rect.maxY * 1/4)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY * 3/4)
        let bottomCenter = CGPoint(x: rect.midX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY * 3/4)
        let topRight = CGPoint(x: rect.maxX, y: rect.maxY * 1/4)
       
        path.move(to: topCenter)
        path.addArc(tangent1End: topCenter, tangent2End: topLeft, radius: cornerRadius)
        path.addArc(tangent1End: topLeft, tangent2End: bottomLeft, radius: cornerRadius)
        path.addArc(tangent1End: bottomLeft, tangent2End: bottomCenter, radius: cornerRadius)
        path.addArc(tangent1End: bottomCenter, tangent2End: bottomRight, radius: cornerRadius)
        path.addArc(tangent1End: bottomRight, tangent2End: topRight, radius: cornerRadius)
        path.addArc(tangent1End: topRight, tangent2End: topCenter, radius: cornerRadius)
        path.addArc(tangent1End: topCenter, tangent2End: topLeft, radius: cornerRadius)

        return path
    }

    public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        let size = proposal.replacingUnspecifiedDimensions(by: .infinity)
        let diameter = Self.diameter(for: size)
        return CGSize(width: diameter, height: diameter / Self.aspectRatio)
    }

    private static func diameter(for size: CGSize) -> CGFloat {
        return min(size.width, size.height * Self.aspectRatio)
    }
}

extension CGSize {
    static var infinity: Self {
        CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
    }
}

#Preview {
    HexagonShape(cornerRadius: 60)
        .padding()
        .previewLayout(.sizeThatFits)
}

import SwiftUI

struct RotatedHexagonShape: Shape {
    private let cornerRadius: CGFloat
    private let offset: CGFloat = 16

    init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let topLeft = CGPoint(x: offset, y: rect.minY)
        let midLeft = CGPoint(x: rect.minX, y: rect.maxY * 1/2)
        let bottomLeft = CGPoint(x: offset, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX - offset, y: rect.maxY)
        let midRight = CGPoint(x: rect.maxX, y: rect.midY)
        let topRight = CGPoint(x: rect.maxX - offset, y: rect.minY)
       
        path.move(to: topLeft)
        path.addArc(tangent1End: topLeft, tangent2End: midLeft, radius: cornerRadius)
        path.addArc(tangent1End: midLeft, tangent2End: bottomLeft, radius: cornerRadius)
        path.addArc(tangent1End: bottomLeft, tangent2End: bottomRight, radius: cornerRadius)
        path.addArc(tangent1End: bottomRight, tangent2End: midRight, radius: cornerRadius)
        path.addArc(tangent1End: midRight, tangent2End: topRight, radius: cornerRadius)
        path.addArc(tangent1End: topRight, tangent2End: topLeft, radius: cornerRadius)
        path.addArc(tangent1End: topLeft, tangent2End: midLeft, radius: cornerRadius)


        return path
    }
}

#Preview {
    Color.red
        .clipShape(RotatedHexagonShape(cornerRadius: 3))
        .frame(height: 54)
        .padding(.horizontal, 16)
}

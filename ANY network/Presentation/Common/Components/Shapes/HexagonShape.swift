import SwiftUI

struct HexagonShape: Shape {
    private let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }
    
    func path(in rect: CGRect) -> Path {
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
}

#Preview {
    Color.red
        .clipShape(HexagonShape(cornerRadius: 30))
        .frame(
            width: UIScreen.main.bounds.width - 10,
            height: tan(Angle(degrees: 30).radians) * (UIScreen.main.bounds.width - 10) * 2)
}

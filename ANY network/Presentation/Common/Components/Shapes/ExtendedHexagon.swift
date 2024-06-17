import SwiftUI

struct ExtendedHexagon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let topLeftCorner = CGPoint(x: 16, y: rect.minY)
        let leftCenter = CGPoint(x: rect.minX, y: rect.midY)
        let bottomLeftCorner = CGPoint(x: 16, y: rect.maxY)
        let bottomRightCorner = CGPoint(x: rect.maxX - 16, y: rect.maxY)
        let centerRight = CGPoint(x: rect.maxX, y: rect.midY)
        let topRightCorner = CGPoint(x: rect.maxX - 16, y: rect.minY)
        let radius = 4.0

        let sumX = topLeftCorner.x + leftCenter.x
        let sumY = topLeftCorner.y + leftCenter.y

        path.move(to: CGPoint(x: sumX / 2, y: sumY / 2))
        path.addArc(tangent1End: leftCenter, tangent2End: bottomLeftCorner, radius: radius)
        path.addArc(tangent1End: bottomLeftCorner, tangent2End: bottomRightCorner, radius: radius)
        path.addArc(tangent1End: bottomRightCorner, tangent2End: centerRight, radius: radius)
        path.addArc(tangent1End: centerRight, tangent2End: topRightCorner, radius: radius)
        path.addArc(tangent1End: topRightCorner, tangent2End: topLeftCorner, radius: radius)
        path.addArc(tangent1End: topLeftCorner, tangent2End: leftCenter, radius: radius)
        path.addArc(tangent1End: leftCenter, tangent2End: bottomLeftCorner, radius: radius)

        return path
    }
}

struct ExtendedHexagonView: View {
    var body: some View {
        ExtendedHexagon()
            .fill(.appPurple)
            .stroke(.appPurple, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
            .frame(maxWidth: .infinity, maxHeight: 56)
            .padding(.horizontal)
            .clipShape(ExtendedHexagon(), style: FillStyle(eoFill: true, antialiased: true))
    }
}

#Preview {
    ExtendedHexagonView()
}

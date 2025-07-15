//
//  TestScreen.swift
//  ANY network
//
//  Created by Danail Vrachev on 15.07.25.
//

import SwiftUI

struct HexagonShape2: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = w / 2

        var path = Path()
        for i in 0..<6 {
            let angle = Angle(degrees: Double(i) * 60 - 30) // -30 for pointy top
            let pt = CGPoint(
                x: center.x + radius * cos(CGFloat(angle.radians)),
                y: center.y + radius * sin(CGFloat(angle.radians))
            )
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }
}

struct TestScreen: View {
    @State var gridModel: HiUScrollableHexGridModel = .init(numberOfCircles: 5)
    let cellSize: CGFloat = 100
    let spacing: CGFloat = 10

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            let (gridWidth, gridHeight, normalizedOrigin, cellStep) = gridGeometry()
            Canvas { context, size in
                drawGrid(context: context, size: size, gridWidth: gridWidth, gridHeight: gridHeight, normalizedOrigin: normalizedOrigin, cellStep: cellStep)
            }
            .frame(width: gridWidth, height: gridHeight)
            .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 14)
        }
    }

    private func gridGeometry() -> (CGFloat, CGFloat, CGPoint, CGSize) {
        let aspectRatio: CGFloat = sqrt(3) / 2
        let w = cellSize
        let h = cellSize * aspectRatio
        let cellStep = CGSize(width: w, height: h)
        let cols = gridModel.gridItems.map { $0.offsetCoordinate.col }
        let rows = gridModel.gridItems.map { $0.offsetCoordinate.row }
        guard let minCol = cols.min(), let _ = cols.max(),
              let minRow = rows.min(), let _ = rows.max() else {
            return (0, 0, .zero, .zero)
        }
        let normalizedOrigin = CGPoint(x: CGFloat(minCol), y: CGFloat(minRow))
        let normalizedX = cols.map { CGFloat($0) }
        let normalizedY = rows.map { CGFloat($0) + 1 / 2 * CGFloat($0 & 1) }
        let gridWidth = (normalizedX.max()! - normalizedX.min()! + 2) * cellStep.width
        let gridHeight = (normalizedY.max()! - normalizedY.min()! + 2) * cellStep.height
        return (gridWidth, gridHeight, normalizedOrigin, cellStep)
    }

    private func drawGrid(context: GraphicsContext, size: CGSize, gridWidth: CGFloat, gridHeight: CGFloat, normalizedOrigin: CGPoint, cellStep: CGSize) {
        let w = cellStep.width
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black))
        for cell in gridModel.gridItems {
            let col = cell.offsetCoordinate.col
            let row = cell.offsetCoordinate.row
            let multiplayer = CGFloat(row > 0 ? -1 : 1)
//            let adjustedBy = abs(row) % 2 == 0 ? 0 : 0
            let adjustedBy = (abs(row) > 1 ? Int(row / 2) * 2 : 0) * (-1)
            let normalizedX = CGFloat(col) - normalizedOrigin.x + 1 / 2 * CGFloat((row + Int(adjustedBy)))
            let normalizedY = CGFloat(row) - normalizedOrigin.y + 2 / 3

            let x = normalizedX * cellStep.width
            let y = normalizedY * cellStep.height

            let hexRect = CGRect(x: x, y: y, width: w, height: w)
            let hexPath = HexagonShape2().path(in: hexRect)
            context.fill(hexPath, with: .color(cell.color))
            // Add 3D inner glow
            let glow = GraphicsContext.Shading.radialGradient(
                Gradient(colors: [Color.white.opacity(0.5), Color.clear]),
                center: .init(x: hexRect.midX, y: hexRect.midY),
                startRadius: 0,
                endRadius: w * 0.6
            )
            context.fill(hexPath, with: glow)
            // Draw cell.priority as centered text
            if let priority = cell.priority {
                let text = Text("\(priority)")
                    .font(.system(size: w * 0.3, weight: .bold))
                    .foregroundColor(.black)
                context.draw(text, at: CGPoint(x: hexRect.midX, y: hexRect.midY), anchor: .center)
            }
        }
    }
}

#Preview {
    TestScreen()
}
struct TestHex: View {
    let colorPack: ColorPack

    var body: some View {
        
        HexagonShape(cornerRadius: 6)
            .foregroundStyle(
                LinearGradient(
                    colors: [colorPack.startColor, colorPack.endColor],
                    startPoint: .init(x: 0, y: 0),
                    endPoint: .init(x: 0, y: 1)
                )
                .shadow(.inner(color: .white.opacity(0.5), radius: 10, x: 0, y: 10))
                .shadow(.inner(color: (Color(hex: "BD8302") ?? .yellow).opacity(0.7), radius: 5, x: 0, y: -4))
                .shadow(.drop(color: (Color(hex: "251B04") ?? .black),radius: 30, x: 0, y: 14))
            )
    }
}

struct ColorPack {
    let startColor: Color
    let endColor: Color
    let pressed: Color
    
    static var colors: [ColorPack] = {
        return [
            .init(
                startColor: Color(hex: "FDDD3B")!,
                endColor: Color(hex: "FFCC00")!,
                pressed: Color(hex: "1F4048")!
            ),
            .init(
                startColor: Color(hex: "3BFD92")!,
                endColor: Color(hex: "05B497")!,
                pressed: Color(hex: "1F4048")!
            ),
            .init(
                startColor: Color(hex: "FD3BD9")!,
                endColor: Color(hex: "FF4A4A")!,
                pressed: Color(hex: "1F4048")!
            ),
            .init(
                startColor: Color(hex: "A3B9FF")!,
                endColor: Color(hex: "00B2FF")!,
                pressed: Color(hex: "1F4048")!
            )
        ]
    }()
}

func generateHexSpiral(maxRadius: Int) -> [(q: Int, r: Int)] {
    let directions = [
        (1, 0), (1, -1), (0, -1),
        (-1, 0), (-1, 1), (0, 1)
    ]
    var results: [(q: Int, r: Int)] = [(0, 0)] // center
    for radius in 1...maxRadius {
        var q = 0 + directions[4].0 * radius
        var r = 0 + directions[4].1 * radius
        for side in 0..<6 {
            for _ in 0..<radius {
                results.append((q, r))
                q += directions[side].0
                r += directions[side].1
            }
        }
    }
    return results
}

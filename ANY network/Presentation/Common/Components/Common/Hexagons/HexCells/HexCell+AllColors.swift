import SwiftUI

extension HexCell {
    static var all: [HexCell] = {
        var array = [HexCell]()
        for row in 0..<12 {
            let colMax = ((row + 1) % 2) != 0 ? 5 : 6
            for col in 0..<colMax {
                let colorEl = HexagonColor.all[array.count]
                let element = HexCell(offsetCoordinate: .init(row: row, col: col), color: colorEl.color.opacity(colorEl.opacity))
                array.append(element)
            }
        }
        return array
    }()
    
    static var inline: [HexCell] = {
        var array = [HexCell]()
        for idx in 0..<20 {
            let top = HexCell(
                offsetCoordinate: .init(row: 0, col: idx),
                color: .appRaisinBlack
            )
            let center = HexCell(
                offsetCoordinate: .init(row: 1, col: idx),
                color: .appRaisinBlack
            )
            let bottom = HexCell(
                offsetCoordinate: .init(row: 2, col: idx),
                color: .appRaisinBlack
            )
            array.append(contentsOf: [top, center, bottom])
        }
        
        return array
    }()
    
    static var middle: [HexCell] = {
        var array = [HexCell]()
        for idx in 0..<120 {
            let element = HexCell(
                offsetCoordinate: .init(row: idx % 5 , col: idx / 5),
                color: .appRaisinBlack
            )
            array.append(element)
        }
        return array
    }()
}

extension HexCell {
    private struct HexagonColor {
        let color: Color
        let opacity: CGFloat
        
        init(color: Color, opacity: CGFloat = 1.0) {
            self.color = color
            self.opacity = opacity
        }
        
        static var all: [HexagonColor] = {
            [
                // Row 1
                .init(color: .white, opacity: 0.01),
                .init(color: .white, opacity: 0.01),
                .init(color: .white, opacity: 0.01),
                .init(color: .white, opacity: 0.01),
                .init(color: .white, opacity: 0.01),
                
                // Row 2
                .init(color: .white, opacity: 0.02),
                .init(color: .white, opacity: 0.01),
                .init(color: .appYellow, opacity: 0.03),
                .init(color: .white, opacity: 0.01),
                .init(color: .clear),
                .init(color: .white, opacity: 0.02),
                
                // Row 3
                .init(color: .white, opacity: 0.01),
                .init(color: .white, opacity: 0.015),
                .init(color: .appViolet),
                .init(color: .white, opacity: 0.015),
                .init(color: .appLightGreen, opacity: 0.08),
                
                // Row 4
                .init(color: .white, opacity: 0.01),
                .init(color: .appDarkPink, opacity: 0.06),
                .init(color: .white, opacity: 0.01),
                .init(color: .white, opacity: 0.01),
                .init(color: .white, opacity: 0.03),
                .init(color: .white, opacity: 0.03),
                
                // Row 5
                .init(color: .white, opacity: 0.02),
                .init(color: .white, opacity: 0.02),
                .init(color: .white, opacity: 0.02),
                .init(color: .white, opacity: 0.02),
                .init(color: .white, opacity: 0.02),
                
                // Row 6
                .init(color: .white, opacity: 0.02),
                .init(color: .appViolet),
                .init(color: .white, opacity: 0.03),
                .init(color: .white, opacity: 0.03),
                .init(color: .appViolet),
                .init(color: .white, opacity: 0.02),
                
                // Row 7
                .init(color: .white, opacity: 0.02),
                .init(color: .appDarkPurple),
                .init(color: .white, opacity: 0.03),
                .init(color: .appDarkPurple),
                .init(color: .white, opacity: 0.02),
                
                // Row 8
                .init(color: .clear),
                .init(color: .appYellow, opacity: 0.04),
                .init(color: .white, opacity: 0.03),
                .init(color: .white, opacity: 0.03),
                .init(color: .white, opacity: 0.03),
                .init(color: .clear),
                
                // Row 9
                .init(color: .clear),
                .init(color: .white, opacity: 0.03),
                .init(color: .appViolet),
                .init(color: .white, opacity: 0.03),
                .init(color: .appPink, opacity: 0.09),
                
                // Row 10
                .init(color: .white, opacity: 0.015),
                .init(color: .white, opacity: 0.03),
                .init(color: .appOrange, opacity: 0.08),
                .init(color: .white, opacity: 0.02),
                .init(color: .clear),
                .init(color: .white, opacity: 0.015),
                
                // Row 11
                .init(color: .white, opacity: 0.012),
                .init(color: .clear),
                .init(color: .white, opacity: 0.012),
                .init(color: .appPurple, opacity: 0.08),
                .init(color: .white, opacity: 0.012),
                
                // Row 12
                .init(color: .white, opacity: 0.02),
                .init(color: .white, opacity: 0.01),
                .init(color: .clear),
                .init(color: .white, opacity: 0.01),
                .init(color: .clear),
                .init(color: .white, opacity: 0.02),
            ]
        }()
    }
}

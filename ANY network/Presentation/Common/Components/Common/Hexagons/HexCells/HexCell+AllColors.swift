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
        for idx in 0..<7 {
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
        let priorityManager = GridPriorityManager()
        for idx in 0..<26 {
            let position = priorityManager.positionMiddle(for: idx)
            let element = HexCell(
                offsetCoordinate: position,
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
                .init(color: .init(hex: "97B6F2")!),
                .init(color: .init(hex: "2BDAD1")!),
                .init(color: .init(hex: "5F3CC9")!),
                .init(color: .init(hex: "388AD1")!),
                .init(color: .init(hex: "13D16B")!),
                .init(color: .init(hex: "8DEF9D")!),
                .init(color: .init(hex: "C379BF")!),
                .init(color: .init(hex: "F8BF4D")!),
                .init(color: .init(hex: "F2ADAD")!),
                .init(color: .init(hex: "2BDAD1")!),
                .init(color: .init(hex: "97B6F2")!),
                .init(color: .init(hex: "97B6F2")!),
                .init(color: .init(hex: "2BDAD1")!),
                .init(color: .init(hex: "5F3CC9")!),
                .init(color: .init(hex: "388AD1")!),
                .init(color: .init(hex: "13D16B")!),
                .init(color: .init(hex: "FFFFFF")!),
                .init(color: .init(hex: "E34284")!),
                .init(color: .init(hex: "466BFF")!),
                .init(color: .init(hex: "FF64FF")!),
                .init(color: .init(hex: "ADF2E6")!),
                .init(color: .init(hex: "CB8DEF")!),
                .init(color: .init(hex: "8481FE")!),
                .init(color: .init(hex: "26B9FB")!),
                .init(color: .init(hex: "6E4CD4")!),
                .init(color: .init(hex: "FF6061")!),
                .init(color: .init(hex: "97B6F2")!),
                .init(color: .init(hex: "4378BD")!),
                .init(color: .init(hex: "5F3CC9")!),
                .init(color: .init(hex: "1CC580")!),
                .init(color: .init(hex: "F8BF4D")!),
                .init(color: .init(hex: "5F3CC9")!),
                .init(color: .init(hex: "5CC8DB")!),
                .init(color: .init(hex: "E9D06D")!),
                .init(color: .init(hex: "97B6F2")!),
                .init(color: .init(hex: "F35AF3")!),
                .init(color: .init(hex: "8DEF9D")!),
                .init(color: .init(hex: "97B6F2")!),
                .init(color: .init(hex: "7CD0FF")!),
                .init(color: .init(hex: "7CD0FF")!),
                .init(color: .init(hex: "5F3CC9")!),
                .init(color: .init(hex: "5F3CC9")!),
                .init(color: .init(hex: "8481FE")!),
                .init(color: .init(hex: "8481FE")!),
                .init(color: .init(hex: "97B6F2")!),
                .init(color: .init(hex: "8DEF9D")!),
                .init(color: .init(hex: "5F3CC9")!),
                .init(color: .init(hex: "7CD0FF")!),
                .init(color: .init(hex: "F35AF3")!),
                .init(color: .init(hex: "D532B2")!),
                .init(color: .init(hex: "CB8DEF")!),
                .init(color: .init(hex: "8481FE")!),
                .init(color: .init(hex: "ADF2E6")!),
                .init(color: .init(hex: "8481FE")!),
                .init(color: .init(hex: "CB8DEF")!),
                .init(color: .init(hex: "FDB756")!),
                .init(color: .init(hex: "8481FE")!),
                .init(color: .init(hex: "C5F2AD")!),
                .init(color: .init(hex: "8481FE")!),
                .init(color: .init(hex: "ADF2E6")!),
                .init(color: .init(hex: "8DEF9D")!),
                .init(color: .init(hex: "6F56FD")!),
                .init(color: .init(hex: "8481FE")!),
                .init(color: .init(hex: "16A78D")!),
                .init(color: .init(hex: "8481FE")!),
                .init(color: .init(hex: "8DEF9D")!),
                .init(color: .init(hex: "8DEF9D")!),
                .init(color: .init(hex: "C379BF")!),
                .init(color: .init(hex: "F8BF4D")!),
                .init(color: .init(hex: "F2ADAD")!),
                .init(color: .init(hex: "2BDAD1")!)
            ]
        }()
    }
}

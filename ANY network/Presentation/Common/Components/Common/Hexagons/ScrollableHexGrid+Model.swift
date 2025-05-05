import Foundation
import SwiftUI

class ScrollableHexGridModel: ObservableObject {
    @Published var gridContentOffset: CGPoint = .zero
    @Published var gridContentSize: CGSize = .zero
    @Published var gridContainerSize: CGSize = .zero
    @Published var gridZoomScale: CGFloat = 1
    @Published var refreshID: UUID = UUID()
    @Published var scrollEnabled: Bool = true

    @MainActor
    let cellSize = CGSize(width: <->85, height: |96.42)

    private let priorityManager = GridPriorityManager()
    private let gridUtilities: GridUtilities = .init(items: HexCell.all)

    var gridItems: [HexCell]
    
    init(gridItems: [HexCell]? = nil) {
        self.gridItems = gridItems ?? HexCell.all
        generateGrid()
    }

    public func refresh() {
        refreshID = UUID()
    }
    
    @MainActor
    public func recenter(paddingBottom: CGFloat = 0) {
        gridContentOffset = CGPoint(x: gridCenter.x, y: gridCenter.y + paddingBottom)
    }
    
    public func zoom(to scale: CGFloat) {
        gridZoomScale = scale
    }
    
    @MainActor
    public func center(on coordinates: OffsetCoordinate) {
        let evenRow = coordinates.row.isMultiple(of: 2)
        let positive = coordinates.row > 0
        
        let hexWidth = cellSize.width * gridZoomScale
        let hexHeight = cellSize.height * gridZoomScale
        let hexSpacing = 8 * gridZoomScale // Adjusted spacing factor

        // Correct x offset calculation for staggered hex grid
        let xOffset = CGFloat(CGFloat(coordinates.col) + (!evenRow ? 0.5 * (positive ? 1 : -1) : 0.0)) * (hexWidth)

        // Adjust yOffset based on row staggering
        let yOffset = CGFloat(coordinates.row) * (hexHeight * 0.75) - 40

        // Apply the calculated offsets to center the grid
        gridContentOffset = CGPoint(
            x: gridCenter.x + xOffset,
            y: gridCenter.y + yOffset
        )
    }
    
    private func generateGrid() {
        var array = [HexCell]()
        var count = 1
        let circles = 9
        for idx in 1..<circles {
            count += idx * 6
        }

        for idx in 0..<count {
            let coords = priorityManager.positionBottom(for: idx)
//            print("index:\(idx) coords:\(coords)")
            let cell = HexCell(offsetCoordinate: coords, color: .appRaisinBlack, priority: idx)
            array.append(cell)
        }
        let coloredGrid = generateGridColors(grid: array)
        gridItems = coloredGrid
        gridUtilities.recalculateGrid(with: gridItems)
    }
    
    private func generateGridColors(grid: [HexCell]) -> [HexCell] {
        var coloredGrid = [HexCell]()
        coloredGrid.reserveCapacity(grid.count)
        
        for cell in grid {
            let offset = (row: -4, col: -2) // The offset we need to put 4, 2 from `HexCell.all` in the center
            if let defaultBackgroundCell = HexCell.all.first(where: {
                $0.offsetCoordinate.row == (cell.offsetCoordinate.row - offset.row) &&
                $0.offsetCoordinate.col == (cell.offsetCoordinate.col - offset.col + (cell.offsetCoordinate.row % 2 != 0 ? 1 : 0))
            }) {
                var coloredHex = cell
                coloredHex.color = defaultBackgroundCell.color
                coloredGrid.append(coloredHex)
            } else {
                var coloredHex = cell
                coloredHex.color = .init(
                    red: .random(in: 0...1),
                    green: .random(in: 0...1),
                    blue: .random(in: 0...1),
                    opacity: .random(in: 0.02...0.035)
                )
                coloredGrid.append(coloredHex)
            }
        }
        
        return coloredGrid
    }

    @MainActor
    private var gridCenter: CGPoint {
        .init(
            x: gridContentSize.width / 2 - gridContainerSize.width / 2 - ((<->cellSize.width / 2 - 4) * gridZoomScale),
            y: gridContentSize.height / 2 - gridContainerSize.height / 2 - 40//+ 80 // keep the center over the sheet
        )
    }
}

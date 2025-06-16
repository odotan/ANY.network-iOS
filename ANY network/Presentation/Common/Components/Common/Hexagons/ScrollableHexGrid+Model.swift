import Foundation
import SwiftUI

class ScrollableHexGridModel: ObservableObject {
    @Published var gridContentOffset: CGPoint = .zero
    @Published var gridContentSize: CGSize = .zero
    @Published var gridContainerSize: CGSize = .zero
    @Published var gridZoomScale: CGFloat = 1
    @Published var refreshID: UUID = UUID()
    @Published var scrollEnabled: Bool = true
    @Published private(set) var isRefreshing: Bool = false

    @MainActor
    let cellSize = CGSize(width: <->85, height: |96.42)

    private let priorityManager = GridPriorityManager()
    private let gridUtilities: GridUtilities = .init(items: HexCell.all)

    var gridItems: [HexCell]
    
    // Grid offset constants based on the grid layout
    private let gridRowOffset: Int = 1  // Adjusted based on actual behavior
    private let gridColOffset: Int = -3  // Adjusted based on actual behavior
    
    init(gridItems: [HexCell]? = nil) {
        self.gridItems = gridItems ?? HexCell.all
        generateGrid()
    }

    public func refresh() {
        isRefreshing = true
        // Capture current scroll position and zoom
        let currentOffset = gridContentOffset
        let currentZoom = gridZoomScale
        
        // Update the refresh ID to trigger re-render
        refreshID = UUID()
        
        // Use async to ensure the refresh state is properly handled
        Task { @MainActor in
            // Small delay to allow the view to update
            try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
            
            // Restore scroll position and zoom if needed
            if gridContentOffset != currentOffset {
                gridContentOffset = currentOffset
            }
            if gridZoomScale != currentZoom {
                gridZoomScale = currentZoom
            }
            
            isRefreshing = false
        }
    }
    
    @MainActor
    public func recenter(paddingBottom: CGFloat = 0) {
        gridContentOffset = CGPoint(x: gridCenter.x, y: gridCenter.y + paddingBottom)
    }
    
    public func zoom(to scale: CGFloat) {
        gridZoomScale = scale
    }
    
    @MainActor
    public func zoomAndCenter(to coordinate: OffsetCoordinate, scale: CGFloat) {
        // Calculate the current position before zooming
        let evenRow = coordinate.row.isMultiple(of: 2)
        
        print("Debug - Original coordinate: \(coordinate)")
        
        // Calculate adjusted coordinates using grid offsets
        let adjustedCol = coordinate.col - gridColOffset
        let adjustedRow = coordinate.row + gridRowOffset
        
        print("Debug - Adjusted coordinate: row: \(adjustedRow), col: \(adjustedCol)")
        
        // Calculate position with current zoom
        let currentHexWidth = cellSize.width * gridZoomScale
        let currentYSpacing = cellSize.height * gridZoomScale * 0.75
        
        // Get current hex position with grid-based offsets
        let currentXOffset = (CGFloat(adjustedCol) * currentHexWidth) + 
            (!evenRow ? currentHexWidth / 2 : 0) + (currentHexWidth / 2)
        let currentYOffset = CGFloat(adjustedRow) * currentYSpacing - 40
        
        print("Debug - Current offsets - X: \(currentXOffset), Y: \(currentYOffset)")
        
        // Calculate current center
        let currentCenterX = gridContentSize.width / 2 - gridContainerSize.width / 2 - ((cellSize.width / 2) * gridZoomScale)
        let currentCenterY = gridContentSize.height / 2 - gridContainerSize.height / 2 - 40
        
        // Get the target hex's current position
        let currentPosition = CGPoint(
            x: currentCenterX + currentXOffset,
            y: currentCenterY + currentYOffset
        )
        
        print("Debug - Current position: \(currentPosition)")
        
        withAnimation(.spring(response: 0.45, dampingFraction: 0.95)) {
            // Update zoom scale
            gridZoomScale = scale
            
            // Calculate new measurements with new zoom
            let newHexWidth = cellSize.width * scale
            let newYSpacing = cellSize.height * scale * 0.75
            
            // Calculate new offsets using grid-based offsets
            let newXOffset = (CGFloat(adjustedCol) * newHexWidth) + 
                (!evenRow ? newHexWidth / 2 : 0) + (newHexWidth / 2)
            let newYOffset = CGFloat(adjustedRow) * newYSpacing - 40
            
            print("Debug - New offsets - X: \(newXOffset), Y: \(newYOffset)")
            
            // Calculate new center
            let newCenterX = gridContentSize.width / 2 - gridContainerSize.width / 2 - ((cellSize.width / 2) * scale)
            let newCenterY = gridContentSize.height / 2 - gridContainerSize.height / 2 - 40
            
            // Calculate the zoom adjustment to maintain position
            let zoomAdjustX = (newXOffset - currentXOffset) * (scale / gridZoomScale)
            let zoomAdjustY = (newYOffset - currentYOffset) * (scale / gridZoomScale)
            
            let finalPosition = CGPoint(
                x: newCenterX + newXOffset - zoomAdjustX,
                y: newCenterY + newYOffset - zoomAdjustY
            )
            
            print("Debug - Final position: \(finalPosition)")
            
            gridContentOffset = finalPosition
        }
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
        let all = HexCell.all

        for cell in grid {
            let offset = (row: -4, col: -2) // The offset we need to put 4, 2 from `HexCell.all` in the center
            if let defaultBackgroundCell = all.first(where: { 
                $0.offsetCoordinate.row == (cell.offsetCoordinate.row - offset.row) &&
                $0.offsetCoordinate.col == (cell.offsetCoordinate.col - offset.col + (cell.offsetCoordinate.row % 2 != 0 ? 1 : 0))
            }) {
                var coloredHex = cell
                coloredHex.color = defaultBackgroundCell.color
                coloredGrid.append(coloredHex)
            } else {
                var coloredHex = cell
                coloredHex.color = all.randomElement()?.color ?? .appRaisinBlack
                coloredGrid.append(coloredHex)
            }
        }
        
        return coloredGrid
    }

    @MainActor
    private var gridCenter: CGPoint {
        .init(
            x: gridContentSize.width / 2 - gridContainerSize.width / 2 - ((cellSize.width / 2) * gridZoomScale),
            y: gridContentSize.height / 2 - gridContainerSize.height / 2 - 40
        )
    }
}

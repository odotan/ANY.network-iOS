import Foundation

/// The position of a hexagon, relative to the selected one.
enum GridHexRelativePosition: CaseIterable {
    case left, upLeft, upRight, right, downRight, downLeft
    
    /// Gets `OffsetCoordinate` relative to the selected hexagon.
    ///
    /// - Parameter rowIsEven: Whether the row of the selected hexagon is even.
    /// - Returns: The offset coordinate relative to the selected hex.
    func getRelativeOffset(rowIsEven: Bool) -> OffsetCoordinate {
        switch self {
        case .left:
            return .init(row: 0, col: -1)
        case .upLeft:
            return .init(row: -1, col: rowIsEven ? -1 : 0)
        case .upRight:
            return .init(row: -1, col: rowIsEven ? 0 : 1)
        case .right:
            return .init(row: 0, col: 1)
        case .downRight:
            return .init(row: 1, col: rowIsEven ? 0 : 1)
        case .downLeft:
            return .init(row: 1, col: rowIsEven ? -1 : 0)
        }
    }
}

/// Contains utility functions for actions to do with a 2D grid of `OffsetCoordinateProviding` items.
class GridUtilities {
    /// A matrix representing the grid.
    private(set) var grid: [[Int]]
    /// A dictionary containing the row number, and its coresponding index in the `grid` property.
    private var indecies: [Int: Int]
    
    /// Creates an object using the items.
    init<T: OffsetCoordinateProviding>(items: [T]) {
        self.grid = Self.transformToMatrix(items: items)
        self.indecies = Self.mapIndeciesToRowValue(items: items)
    }
    
    /// Gets the offset coordinates of the adjacent cells.
    /// 
    /// - Parameter cell: The cell, whose adjacent coordinates we want to get.
    /// - Returns: The offset coordinates of adjacent cells.
    ///
    /// This function will return the coordinates withought checking if they exist in the grid,
    /// you need to filter out the coordinates that dont exist in your grid when you are using them.
    func getOffsetCoordinateOfAdjacentCells<T: OffsetCoordinateProviding>(to cell: T) -> [OffsetCoordinate] {
        var adjacentCells = [OffsetCoordinate]()
        
        let row = cell.offsetCoordinate.row
        let col = cell.offsetCoordinate.col
        
        let range = -1...1

        for devRow in range {
            for devCol in range {
                let relativeOffset = OffsetCoordinate(row: devRow, col: devCol)
                if GridHexRelativePosition
                    .allCases
                    .compactMap({ $0.getRelativeOffset(rowIsEven: row.isMultiple(of: 2)) })
                    .contains(relativeOffset) {
                    adjacentCells.append(.init(row: row + devRow, col: col + devCol))
                }
            }
        }
        
        return adjacentCells
    }
    
    /// Recalculates the grid using the new items.
    ///
    /// - Parameter items: The items used to generate the grid.
    ///
    /// This function should only be called if the number of items has changed from the previous grid.
    func recalculateGrid<T: OffsetCoordinateProviding>(with items: [T]) {
        self.grid = Self.transformToMatrix(items: items)
        self.indecies = Self.mapIndeciesToRowValue(items: items)
    }
    
    /// Maps the `OffsetCoordinate` `row` to the coresponding index of the row in the generated matrix.
    ///
    /// - Parameter items: The items used to generate the grid.
    /// - Returns: The dictionary containing the mapped values.
    private static func mapIndeciesToRowValue<T: OffsetCoordinateProviding>(items: [T]) -> [Int: Int] {
        guard !items.isEmpty else { return [:] }
              // Coordinate: Index
        var indecies = [Int: Int]()
        let minRow = items.min { $0.offsetCoordinate.row < $1.offsetCoordinate.row }!.offsetCoordinate.row
        let maxRow = items.max { $0.offsetCoordinate.row < $1.offsetCoordinate.row }!.offsetCoordinate.row
        var index = 0
        
        for row in minRow..<maxRow {
            indecies.updateValue(index, forKey: row)
            index += 1
        }
        return indecies
    }
    
    /// Transforms an array of `OffsetCoordinateProviding` items to a 2D matrix.
    ///
    /// - Parameter items: The items used to generate the matrix.
    ///- Returns: The generated matrix.
    private static func transformToMatrix<T: OffsetCoordinateProviding>(items: [T]) -> [[Int]] {
        guard !items.isEmpty else { return [] }
        
        var matrix = [[Int]]()
        let ordered = items.sorted { $0.offsetCoordinate.row < $1.offsetCoordinate.row }
        let minRow = items.min { $0.offsetCoordinate.row < $1.offsetCoordinate.row }!.offsetCoordinate.row
        let maxRow = items.max { $0.offsetCoordinate.row < $1.offsetCoordinate.row }!.offsetCoordinate.row
        var rowNum = 0
        
        for row in minRow..<maxRow {
            let thisRow = ordered
                .filter { $0.offsetCoordinate.row == row }
                .sorted { $0.offsetCoordinate.col < $1.offsetCoordinate.col }
            guard !thisRow.isEmpty else { continue }
            
            matrix.insert(contentsOf: [thisRow.compactMap { $0.offsetCoordinate.col }], at: rowNum)
            rowNum += 1
        }
        
        return matrix
    }
}

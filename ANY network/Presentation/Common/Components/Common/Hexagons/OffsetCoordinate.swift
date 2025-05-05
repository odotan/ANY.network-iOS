import Foundation

public struct OffsetCoordinate: Hashable, Equatable, Codable {
    public var row: Int
    public var col: Int

    public init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
}

public protocol OffsetCoordinateProviding: Equatable {
    var offsetCoordinate: OffsetCoordinate { get }
}

extension OffsetCoordinate: AdditiveArithmetic {
    public static func - (lhs: OffsetCoordinate, rhs: OffsetCoordinate) -> OffsetCoordinate {
        .init(row: lhs.row - rhs.row, col: lhs.col - rhs.col)
    }
    
    public static func + (lhs: OffsetCoordinate, rhs: OffsetCoordinate) -> OffsetCoordinate {
        .init(row: lhs.row + rhs.row, col: lhs.col + rhs.col)
    }
    
    public static var zero: OffsetCoordinate {
        .init(row: 0, col: 0)
    }
}

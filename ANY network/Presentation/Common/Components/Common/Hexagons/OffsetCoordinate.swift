import Foundation

public struct OffsetCoordinate: Hashable, Equatable, Codable {
    public var row: Int
    public var col: Int

    public init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
}

public protocol OffsetCoordinateProviding {
    var offsetCoordinate: OffsetCoordinate { get }
}

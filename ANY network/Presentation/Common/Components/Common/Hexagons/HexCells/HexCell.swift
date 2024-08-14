import SwiftUI

struct HexCell: Identifiable, OffsetCoordinateProviding, HexCellProtocol, Equatable {
    var id: Int { offsetCoordinate.hashValue }
    var offsetCoordinate: OffsetCoordinate
    var color: Color
    var priority: Int?
    
    init(offsetCoordinate: OffsetCoordinate, color: Color = .clear, priority: Int? = nil) {
        self.offsetCoordinate = offsetCoordinate
        self.color = color
        self.priority = priority
    }
    
    static func ==(lhs: HexCell, rhs: HexCell) -> Bool {
        lhs.id == rhs.id
    }
}

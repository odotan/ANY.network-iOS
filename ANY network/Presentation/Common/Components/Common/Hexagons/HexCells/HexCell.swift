import SwiftUI

struct HexCell: Identifiable, OffsetCoordinateProviding, HexCellProtocol, Equatable {
    var id: Int { offsetCoordinate.hashValue }
    var offsetCoordinate: OffsetCoordinate
    var color: Color
    var priority: Int?
    var isSelected: Bool
    
    init(offsetCoordinate: OffsetCoordinate, color: Color = .clear, priority: Int? = nil, isSelected: Bool = false) {
        self.offsetCoordinate = offsetCoordinate
        self.color = color
        self.priority = priority
        self.isSelected = isSelected
    }
    
    static func ==(lhs: HexCell, rhs: HexCell) -> Bool {
        lhs.id == rhs.id
    }
}

import Foundation

struct GridPriorityManager {

    func positionTop(for index: Int) -> OffsetCoordinate {
        let offset = index % 3
        
        var row: Int!
        switch offset {
        case 0:
            row = 0
        case 1:
            row = 1
        case 2:
            row = -1
        default:
            row = 0
        }
        
        let layer = index / 3 + 1
        let col = (layer % 2 == 0) ? layer / 2 : (-1) * layer / 2
        
        return .init(row: row, col: col)
    }
    
    func positionMiddle(for index: Int) -> OffsetCoordinate {
        if index == 0 {
            return .init(row: 0, col: 0)
        }
        
        var offset = index % 6
        offset = offset == 0 ? 6 : offset
        let side = abs(1 - offset % 2)
        let layer = (index - 1) / 6

        var col: Int!
        switch side {
        case 0: // right
            col = layer + (offset != 5 ? 1 : 0)
        case 1: // left
            col = (-1) * (layer + (offset != 4 ? 1 : 0))
        default:
            col = 0
        }
        
        var row: Int!
        switch offset {
        case 1, 2:
            row = 0
        case 3, 4:
            row = -1
        case 5, 6:
            row = 1
        default:
            row = 0
        }
        
//        print(index, row!, col!, offset, layer, side)

        return .init(row: row, col: col)
    }
    
    func positionBottom(for index: Int) -> OffsetCoordinate {
        if index == 0 {
            return .init(row: 0, col: 0)
        }
        
        var layer = 1
        var count = 1
        
        while count + 6 * layer <= index {
            count += 6 * layer
            layer += 1
        }
        
        let positionInLayer = index - count
        let sideLength = layer
        let side = positionInLayer / sideLength
        let offset = positionInLayer % sideLength
        
        switch side {
        case 0: // 1
            return .init(row: offset, col: layer - (offset + 1) / 2)
        case 1: // 2
            if layer == 1 {
                return .init(row: 1, col: 0)
            }
            
            return .init(row: layer, col: layer / 2 - offset)
        case 2: // 3
            if layer == 1 {
                return .init(row: 1, col: -1)
            }
            
            return .init(row: layer - offset, col: -((layer + 1) / 2 + (offset + (layer % 2 == 0 ? 1 : 0)) / 2))
        case 3: // 4
            if layer == 1 {
                return .init(row: 0, col: -1)
            }
            return .init(row: -offset, col: -(layer - offset + offset / 2))
        case 4: // 5
            if layer == 1 {
                return .init(row: -1, col: 0)
            }
            return .init(row: -layer, col: -(layer / 2) + offset)
        case 5: // 6
            if layer == 1 {
                return .init(row: -1, col: 1)
            }
            return .init(row: -layer + offset, col: (layer + 1) / 2 + (layer % 2 == 0 ? (offset + 1) / 2 : (offset / 2)))
        default:
            return .init(row: 0, col: 0)
        }
        
    }
}

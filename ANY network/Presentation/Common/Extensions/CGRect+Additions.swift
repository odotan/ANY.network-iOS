import Foundation

extension CGRect {
    var centerPoint: CGPoint {
        .init(x: maxX - (width / 2), y: maxY - (height / 2))
    }
}

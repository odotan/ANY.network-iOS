import Foundation

extension CGPoint {
    func integerPartEqualTo(_ point: CGPoint) -> Bool {
        let roundedSelf = CGPoint(x: self.x.rounded(), y: self.y.rounded())
        let roundedComp = CGPoint(x: point.x.rounded(), y: point.y.rounded())
        return roundedSelf.equalTo(roundedComp)
    }
}

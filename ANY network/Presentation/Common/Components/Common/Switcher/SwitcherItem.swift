import SwiftUI

struct SwitcherItem: Identifiable, Equatable {
    var id: String = UUID().uuidString
    var imageName: ImageResource?
}

extension Array where Element == SwitcherItem {
    func duplicate(repetitions: Int = 2) -> [SwitcherItem] {
        var temp = [SwitcherItem]()
        for _ in 0..<repetitions {
            self.forEach {
                temp.append($0)
            }
        }
        return temp
    }
}

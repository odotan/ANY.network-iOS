import SwiftUI

struct SwitcherItem: Identifiable, Equatable {
    var id: String = UUID().uuidString
    var imageName: ImageResource?
}

extension Array {
    func duplicate(repetitions: Int = 2) -> [Element] {
        var temp = [Element]()
        for _ in 0..<repetitions {
            self.forEach {
                temp.append($0)
            }
        }
        return temp
    }
}

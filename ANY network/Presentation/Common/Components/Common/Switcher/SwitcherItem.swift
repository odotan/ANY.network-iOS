import SwiftUI

struct SwitcherItem: Identifiable, Equatable {
    var id: String = UUID().uuidString
    var imageName: ImageResource?
}

import SwiftUI

protocol HexCellProtocol {
    var color: Color { get set }
    var pressed: (() -> Void)? { get set }
}

extension HexCellProtocol {
    var pressed: (() -> Void)? {
        get { return {} }
        set { }
    }
}

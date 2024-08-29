import SwiftUI

protocol HexCellProtocol {
    var color: Color { get }
    var pressed: (() -> Void)? { get set }
}

extension HexCellProtocol {
    var pressed: (() -> Void)? {
        get { return {} }
        set { }
    }
}

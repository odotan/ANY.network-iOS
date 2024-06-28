import SwiftUI

prefix operator <->
prefix operator |

private let dWidth: CGFloat = 375
private let dHeight: CGFloat = 812

@MainActor
public prefix func <-> (_ value: CGFloat) -> CGFloat {
    let width = UIScreen.main.bounds.size.width
    let percent = value / dWidth

    return width * percent
}

@MainActor
public prefix func | (_ value: CGFloat) -> CGFloat {
    let height = UIScreen.main.bounds.size.height
    let percent = value / dHeight

    return height * percent
}

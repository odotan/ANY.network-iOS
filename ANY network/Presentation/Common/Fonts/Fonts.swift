import SwiftUI

fileprivate let montseratRegular = "Montserrat-Regular"
fileprivate let montseratMedium = "Montserrat-Medium"
fileprivate let montseratSemiBold = "Montserrat-SemiBold"
fileprivate let montseratBold = "Montserrat-Bold"

extension Font {
    static func montserat(size: CGFloat, weight: Weight = .regular) -> Font {
        var name = ""
        switch weight {
        case .regular:
            name = montseratRegular
        case .medium:
            name = montseratMedium
        case .semibold:
            name = montseratSemiBold
        case .bold:
            name = montseratBold
        default:
            name = montseratRegular
        }
            
        return Font.custom(name, size: size)
    }
}

import SwiftUI

struct HexagonItem: Hashable {
    var color: Color
    var opacity: CGFloat
    var type: HexagonType
    
    
    init(type: HexagonType = .various, color: Color? = nil, opacity: CGFloat? = nil, opacitySF: CGFloat = 1.0) {
        self.type = type
        self.color = type.color
        
        if let color = color {
            self.color = color
        }
        self.opacity = (opacity ?? CGFloat.random(in: 0.38 ..< 0.45)) * opacitySF
    }
}

let defaultHexagonItemsList: [HexagonItem] = {[
    // Row 1
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .clear),
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .clear),
    .init(color: .clear),
    
    // Row 2
    .init(color: .clear),
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .clear),
    .init(color: .clear),
    
    // Row 3
    .init(color: .appPurple, opacity: 0.17, opacitySF: 0.2),
    .init(color: .clear),
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .clear),
    .init(color: .clear),

    // Row 4
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .appOrange, opacity: 0.56, opacitySF: 0.126), // type
    .init(color: .clear),
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .clear),
    
    // Row 5
    .init(color: .appLightPink, opacity: 0.8, opacitySF: 0.126), // type
    .init(color: .appDarkBlue, opacity: 0.09), // type FACEBOOK
    .init(color: .appPink, opacity: 0.09), // type FB MESSANGER
    .init(color: .appGreen, opacity: 0.39, opacitySF: 0.126), // type
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .clear),
    
    // Row 6
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .appLightBlue, opacity: 0.11), // type PHONE
    .init(type: .photo, color: .appPurple, opacity: 0.36), // type PHOTO
    .init(color: .appOrange, opacity: 0.11), // type INSTAGRAM
    .init(color: .clear),
    .init(color: .clear),
    
    // Row 7
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(type: .contacts, color: .appGreen, opacity: 0.08), // type Phonebook
    .init(color: .appYellow, opacity: 0.08), // Type EMAIL
    .init(color: .appOrange, opacity: 0.7, opacitySF: 0.126),
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .clear),
    
    // Row 8
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .appYellow, opacity: 0.39, opacitySF: 0.2), // Type
    .init(color: .appLightBlue, opacity: 0.5, opacitySF: 0.2), // Type
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .clear),
    
    // Row 9
    .init(color: .clear),
    .init(color: .appPurple, opacity: 0.15, opacitySF: 0.2), // Type
    .init(color: .appOrange, opacity: 0.44, opacitySF: 0.2), // Type
    .init(color: .clear),
    .init(color: .clear),
    .init(color: .clear),
    
    // Row 10
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .clear),
    
    // Row 11
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .appPurple, opacity: 0.10, opacitySF: 0.2),
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .clear),
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .clear),
    
    // Row 12
    .init(color: .appYellow, opacity: 0.10, opacitySF: 0.2),
    .init(color: .clear),
    .init(color: .appOrange, opacity: 0.10, opacitySF: 0.2),
    .init(color: .appPink, opacity: 0.10, opacitySF: 0.2),
    .init(color: .appGray, opacity: 0.10, opacitySF: 0.2),
    .init(color: .clear)
]}()

let backgroundHexagonItemsList: [HexagonItem] = {[
    // Row 1
    .init(color: .clear),
    .init(color: .white, opacity: 0.01),
    .init(color: .white, opacity: 0.01),
    .init(color: .white, opacity: 0.01),
    .init(color: .white, opacity: 0.01),
    .init(color: .white, opacity: 0.01),
    .init(color: .white, opacity: 0.01),
    
    // Row 2
    .init(color: .white, opacity: 0.01),
    .init(color: .white, opacity: 0.02),
    .init(color: .appYellow, opacity: 0.03),
    .init(color: .white, opacity: 0.01),
    .init(color: .clear),
    .init(color: .white, opacity: 0.02),
    .init(color: .white, opacity: 0.01),
    
    // Row 3
    .init(color: .clear),
    .init(color: .white, opacity: 0.01),
    .init(color: .white, opacity: 0.02),
    .init(color: .clear),
    .init(color: .white, opacity: 0.02),
    .init(color: .appGreen, opacity: 0.08),
    .init(color: .white, opacity: 0.01),
    
    // Row 4
    .init(color: .white, opacity: 0.01),
    .init(color: .appPink, opacity: 0.06),
    .init(color: .clear),
    .init(color: .clear),
    .init(color: .white, opacity: 0.03),
    .init(color: .clear),
    .init(color: .white, opacity: 0.01),
    
    // Row 5
    .init(color: .clear),
    .init(color: .clear),
    .init(color: .clear),
    .init(color: .clear),
    .init(color: .clear),
    .init(color: .white, opacity: 0.02),
    .init(color: .white, opacity: 0.01),
    
    // Row 6
    .init(color: .white, opacity: 0.02),
    .init(color: .clear),
    .init(color: .clear),
    .init(color: .clear),
    .init(color: .clear),
    .init(color: .white, opacity: 0.02),
    .init(color: .white, opacity: 0.01),
    
    // Row 7
    .init(color: .clear),
    .init(color: .white, opacity: 0.02),
    .init(color: .white, opacity: 0.03),
    .init(color: .clear),
    .init(color: .white, opacity: 0.03),
    .init(color: .appBlue, opacity: 0.13),
    .init(color: .white, opacity: 0.01),
    
    // Row 8
    .init(color: .clear),
    .init(color: .appYellow, opacity: 0.04),
    .init(color: .clear),
    .init(color: .clear),
    .init(color: .clear),
    .init(color: .clear),
    .init(color: .white, opacity: 0.01),
    
    // Row 9
    .init(color: .clear),
    .init(color: .clear),
    .init(color: .white, opacity: 0.03),
    .init(color: .clear),
    .init(color: .white, opacity: 0.03),
    .init(color: .appPink, opacity: 0.09),
    .init(color: .white, opacity: 0.01),
    
    // Row 10
    .init(color: .white, opacity: 0.02),
    .init(color: .white, opacity: 0.03),
    .init(color: .appOrange, opacity: 0.08),
    .init(color: .white, opacity: 0.02),
    .init(color: .clear),
    .init(color: .white, opacity: 0.02),
    .init(color: .white, opacity: 0.01),
    
    // Row 11
    .init(color: .clear),
    .init(color: .white, opacity: 0.01),
    .init(color: .clear),
    .init(color: .white, opacity: 0.01),
    .init(type: .action),
    .init(color: .white, opacity: 0.01),
    .init(color: .white, opacity: 0.01),
    
    // Row 12
    .init(color: .white, opacity: 0.02),
    .init(color: .white, opacity: 0.01),
    .init(color: .clear),
    .init(color: .white, opacity: 0.01),
    .init(color: .clear),
    .init(color: .white, opacity: 0.02),
    .init(color: .white, opacity: 0.01)
]}()

import SwiftUI

struct ColorHexCell: View, HexCellProtocol {
    var color: Color
    
    var body: some View {
        color
    }
}

#Preview {
    ColorHexCell(color: .red)
}

//
//  ColorHexCell.swift
//  ANY network
//
//  Created by Danail Vrachev on 13.08.24.
//

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

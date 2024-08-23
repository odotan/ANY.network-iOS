import SwiftUI

struct AvatarHexCell: View, HexCellProtocol {
    var imageData: Data?
    var color: Color
    var pressed: (() -> Void)
    
    init(imageData: Data? = nil, color: Color, pressed: @escaping () -> Void = { }) {
        self.imageData = imageData
        self.color = color
        self.pressed = pressed
    }
    
    @ViewBuilder @MainActor
    var image: some View {
        if let data = imageData, let image = UIImage(data: data) {
//            AsyncImageWithCache(imageData: data, cacheKey: "\(data.hashValue)")
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            Image(.avatar)
                .resizable()
                .frame(width: <->26.37, height: |30.7)
        }
    }

    var body: some View {
        Button(action: pressed) {
            color.overlay(image)
        }.buttonStyle(.plain)
    }
}

#Preview {
    AvatarHexCell(imageData: nil, color: Color.blue) { }
}

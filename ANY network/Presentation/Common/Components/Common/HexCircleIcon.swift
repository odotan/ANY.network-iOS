import SwiftUI

struct HexCircleIcon: View {
    private let image: Image
    private let background: Color
    
    init(image: ImageResource, background: Color) {
        self.image = Image(image)
        self.background = background
    }
    
    init(image: Image, background: Color) {
        self.image = image
        self.background = background
    }
    
    var body: some View {
        Circle()
            .fill(background)
            .frame(width: <->24, height: |24)
            .overlay {
                image
                    .resizable()                
                    .frame(width: <->12, height: |12)
                    .scaledToFit()
            }
    }
}

#Preview {
    HexCircleIcon(image: .startFillIcon, background: .appYellow)
}

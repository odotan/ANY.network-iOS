import SwiftUI

struct AvatarHexCell: View, HexCellProtocol {
    let contact: Contact
    private var contactImage: Image?
    var color: Color
    let size: CGSize?
    var pressed: ((CGPoint?) -> Void)
    
    private var tapGesture = TapGesture()
    
    init(
        contact: Contact,
        color: Color = .clear,
        size: CGSize? = nil,
        pressed: @escaping (CGPoint?) -> Void = { _ in }
    ) {
        self.contact = contact
        self.color = color
        self.size = size
        self.pressed = pressed
        guard let imageData = contact.imageData,
              let uiImage = UIImage(data: imageData) else {
            return
        }
        self.contactImage = Image(uiImage: uiImage)
    }
    
    @ViewBuilder @MainActor
    var image: some View {
        if let contactImage {
//            AsyncImageWithCache(imageData: data, cacheKey: "\(data.hashValue)")
            contactImage
                .resizable()
                .scaledToFill()
                .frame(width: size?.width, height: size?.height)
        } else {
            Color.appRaisinBlack
                .overlay {
                    Text(contact.fullName)
                        .font(Font.montserat(size: 20, weight: .bold))
                        .minimumScaleFactor(0.3)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding()

//                    Text(contact.abbreviation)
//                        .font(Font.montserat(size: 20, weight: .bold))
//                        .foregroundStyle(.white)
                }
                .frame(width: size?.width, height: size?.height)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            Button(action: {
                let globalTapLocation = CGPoint(
                    x: 0 + geometry.frame(in: .global).minX,
                    y: 0 + geometry.frame(in: .global).minY
                )
                
                pressed(globalTapLocation)
            }) {
                color.overlay(image)
            }
            .buttonStyle(.plain)
            .clipShape(HexagonShape(cornerRadius: 6))
//            .simultaneousGesture(
//                DragGesture(minimumDistance: 0)
//                    .onEnded { value in
//                        let globalTapLocation = CGPoint(
//                            x: 0 + geometry.frame(in: .global).minX,
//                            y: 0 + geometry.frame(in: .global).minY
//                        )
//                        
//                        pressed(globalTapLocation)
//                    }
//            )
        }
    }
}

#Preview {
    AvatarHexCell(contact: .testContact, color: Color.blue, size: .init(width: <->26.37, height: |30.7)) { _ in }
}

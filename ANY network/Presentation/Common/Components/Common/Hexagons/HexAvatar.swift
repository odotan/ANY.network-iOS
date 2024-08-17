import SwiftUI

struct HexAvatar: View {
    private let image: Image
    private let contactBy: Image
    private let isMe: Bool

    init(image: Image, contactBy: Image, isMe: Bool = false) {
        self.image = image
        self.contactBy = contactBy
        self.isMe = isMe
    }

    init(image: ImageResource, contactBy: ImageResource, isMe: Bool = false) {
        self.image = Image(image)
        self.contactBy = Image(contactBy)
        self.isMe = isMe
    }

    var body: some View {
#warning("Added fill with opaque white for background since the avatars' backgrounds are transparent. Remove later if necessary!")
        image
            .resizable()
            .frame(width: <->80, height: |90)
            .clipShape(HexagonShape(cornerRadius: 6))
            .background(
                HexagonShape(cornerRadius: 6)
                    .fill(.white.opacity(0.7))
            )
            .overlay {
                ZStack {
                    if isMe {
                        HexagonShape(cornerRadius: 6)
                            .fill(.appPurple.opacity(0.3))
                        HexagonShape(cornerRadius: 6)
                        .stroke(.appPurple, lineWidth: 2)
                    }
                }
            }
            .overlay(alignment: isMe ? .bottom : .bottomTrailing) {
                if isMe {
                    Image(.editProfile)
                        .resizable()
                        .frame(width: <->24, height: |24)
                        .padding(.bottom, 8)
                } else {
                    Group {
                        #warning("Make fill color dynamic depending on contact method")
                        Circle()
                            .fill(.appGreen)
                            .frame(width: <->24, height: |24)
                        contactBy
                            .resizable()
                            .scaledToFit()
                            .frame(width: <->12, height: |12)
                    }
                    .padding(.bottom, 5)
                    .padding(.trailing, 7)
                }
            }
    }
}

#Preview {
    let icons: [ImageResource] = [.phoneIcon, .emailYellowIcon, .phoneGreenIcon, .facebookIcon, .blackberryMessengerIcon, .blackberryMessengerIcon]

    return ZStack {
        Color.appBackground.ignoresSafeArea()
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(1..<8) { index in
                    let name = "avatar\(index)x3"
                    HexAvatar(image: Image(name), contactBy: Image(icons.randomElement()!), isMe: name == "avatar3x3" )
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

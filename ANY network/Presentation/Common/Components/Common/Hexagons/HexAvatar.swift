import SwiftUI

struct ContactInteractionPresentable {
    let value: LabeledValue
    let image: Image
    let background: Color

    init(value: LabeledValue, image: Image? = nil, background: Color? = nil) {
        self.value = value // cInteraction.interaction
        
        if let image {
            self.image = image
        } else {
            self.image = switch value.infoType {
            case is PhoneNumberType:
                Image(.phoneWhiteIcon)
            case is EmailAddressType:
                Image(.emailWhiteIcon)
            default:
                Image(.closeIcon)
            }
        }

        if let background {
            self.background = background
        } else {
            self.background = switch value.infoType {
            case is PhoneNumberType:
                    .appLightGreen
            case is EmailAddressType:
                    .appYellow
            default:
                    .red
            }
        }
    }
}

struct HexAvatar: View {
    @Binding private var isEditing: Bool
    private let interaction: ContactInteractionPresentable
    @State private var image: Image?
    private let isMe: Bool
    private let action: () -> Void
    private let deleteAction: (() -> Void)?

    init(
        isEditing: Binding<Bool> = .constant(false),
        interaction: ContactInteractionPresentable,
        isMe: Bool = false,
        action: @escaping () -> Void,
        deleteAction: (() -> Void)? = nil
    ) {
        self._isEditing = isEditing
        self.interaction = interaction
        self.isMe = isMe
        self.action = action
        self.deleteAction = deleteAction
//        if let imageData = interaction.contact.imageData,
//           let uiImage = UIImage(data: imageData) {
//            let image = Image(uiImage: uiImage)
//            self._image = State(initialValue: image)
//        } else {
//            self.image = nil
//        }
    }

    var body: some View {
        Button(action: { }) {
            icon
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
                        HexCircleIcon(image: interaction.image, background: interaction.background)
                            .padding(.bottom, 6)
                            .padding(.trailing, 8)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if let deleteAction {
                        Button(action: deleteAction) {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .foregroundStyle(.white)
                                .frame(width: <->24, height: |24)
                        }
                        .padding(.top, 12)
                    }
                }
                .onTapGesture { action() }
        }
    }

    @MainActor
    @ViewBuilder
    private var icon: some View {
        if let image {
            image
                .resizable()
                .scaledToFill()
                .frame(maxWidth: <->75, maxHeight: |90)
        } else {
            Color.appRaisinBlack
                .overlay {
                    Text(" ") // interaction.contact.abbreviation)
                        .font(Font.montserat(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }
        }
    }
}

//#Preview {
//    return ZStack {
//        Color.appBackground.ignoresSafeArea()
//
//        ScrollView(.horizontal) {
//            HStack(spacing: 8) {
//                HexAvatar(
//                    interaction: .init(interaction: .testInteraction),
//                    isMe: false,
//                    action: { }
//                )
//
//                HexAvatar(
//                    interaction: .init(interaction: .testInteraction),
//                    isMe: false,
//                    action: { }
//                )
//
//                HexAvatar(
//                    interaction: .init(interaction: .testInteraction),
//                    isMe: true,
//                    action: { }
//                )
//            }
//        }
//    }
//}

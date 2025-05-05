import SwiftUI

struct AssignYourContactPopup: View {
    private var action: () -> Void
//    private var onDismiss: () -> Void

    init(action: @escaping () -> Void/*, onDismiss: @escaping () -> Void*/) {
        self.action = action
//        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 0) {
                Image(.contactBook)
                    .resizable()
                    .scaledToFit()
                    .frame(width: <->56, height: |64)
                    .padding(.horizontal, <->18)
                    .padding(.top, |10)

                VStack(alignment: .leading, spacing: |8) {
                    Text(Constants.Strings.title)
                        .font(Font.montserat(size: 15, weight: .bold))

                    Text(
                        """
                        \(Constants.Strings.description)
                        """
                    )
                    .font(Font.montserat(size: 13))
                    .minimumScaleFactor(0.7)
                    .lineLimit(4)
                }
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .padding(.trailing, 27)
            }
            .padding(.top, |21)

            Button(action: action) {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.init(hex: "545458") ?? .white)
                        .opacity(0.65)
                        .background(.appBackground)
                        .frame(height: 0.33)
                        .frame(maxWidth: .infinity)
                    Text(Constants.Strings.continueTxt)
                        .font(Font.montserat(size: 17, weight: .semibold))
                        .foregroundStyle(.appGreen)
                        .padding(.vertical, |11)
                }
                .frame(maxWidth: .infinity)
            }.buttonStyle(.plain)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white.opacity(0.05))
        )
//        .overlay(alignment: .topTrailing) {
//            Button(action: onDismiss) {
//                Circle()
//                    .fill(.white.opacity(0.1))
//                    .background(.appBackground)
//                    .overlay {
//                        Image(.closeIcon)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: <->9, height: |9)
//                    }
//            }
//            .frame(width: <->24, height: |24)
//            .clipShape(Circle())
//            .offset(x: <->5, y: |(-5))
//        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.top)
    }

    struct Constants {
        enum Strings {
            static let title = "Select Your Contact Card?"
            static let description = "In order to complete your experience, please select your contact card."
            static let continueTxt = "Ready to Select"
        }
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        AssignYourContactPopup(action: { })
    }
}

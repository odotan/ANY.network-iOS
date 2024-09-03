import SwiftUI

struct CreateContactCardPopup: View {
    @State private var width: CGFloat = .zero
    private var onDismiss: () -> Void

    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }

    var body: some View {
        HStack(spacing: 0) {
            Image(.bell)
                .resizable()
                .scaledToFit()
                .frame(width: <->33, height: |42)
                .frame(width: width / 4)
                .padding(.top, |10)
            
            VStack(alignment: .leading, spacing: |8) {
                Text(Constants.Strings.title)
                    .font(Font.montserat(size: 15, weight: .bold))

                Text(Constants.Strings.tapOnYourHexagon)
                    .font(Font.montserat(size: 13))
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
            .multilineTextAlignment(.leading)
            .padding(.trailing, 27)
            .padding(.top, |21)
        }
        .padding(.bottom, 25)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white.opacity(0.05))
        )
        .overlay(alignment: .topTrailing) {
            Button(action: onDismiss) {
                Circle()
                    .fill(.white.opacity(0.1))
                    .background(.appBackground)
                    .overlay {
                        Image(.closeIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: <->9, height: |9)
                    }
            }
            .frame(width: <->24, height: |24)
            .clipShape(Circle())
            .offset(x: <->5, y: |(-5))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .background(
            GeometryReader { reader in
                Color.clear
                    .onAppear { self.width = reader.size.width }
            }
        )
    }

    struct Constants {
        enum Strings {
            static let title = "Create your contact card?"
            static let tapOnYourHexagon = "Tap your hexagon in the grid to create or edit your card. Tap other hexagons to add or edit contacts."
        }
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        CreateContactCardPopup(onDismiss: { })
    }
}

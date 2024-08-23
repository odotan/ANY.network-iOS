import SwiftUI

struct SyncContactsPopup: View {
    private var action: () -> Void
    private var onDismiss: () -> Void

    init(action: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        self.action = action
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 0) {
                Image(.contactBook)
                    .resizable()
                    .scaledToFit()
                    .frame(width: <->56, height: |64)
                    .padding(.trailing, 18)
                    .padding(.top, |10)

                VStack(alignment: .leading, spacing: |8) {
                    Text(Constants.Strings.title)
                        .font(Font.montserat(size: 15, weight: .bold))

                    Text(
                        """
                        \(Constants.Strings.newExperience)

                        \(Constants.Strings.shared)
                        """
                    )
                    .font(Font.montserat(size: 13))
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
                    Text(Constants.Strings.sync)
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
        .padding(.top)
    }

    struct Constants {
        enum Strings {
            static let title = "Sync contacts?"
            static let newExperience = "Enjoy a new contacts experience."
            static let shared = "Your contacts will not be shared with\nANY network without your consent."
            static let sync = "Sync"
        }
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        SyncContactsPopup(action: { }, onDismiss: { })
    }
}

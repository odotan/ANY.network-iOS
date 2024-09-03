import SwiftUI

struct FullscreenHexagonPopup: View {
    private let message: String
    private let acceptButton: FullscreenHexagonPopup.PopupButton
    private let cancelButton: FullscreenHexagonPopup.PopupButton

    init(message: String, acceptButton: FullscreenHexagonPopup.PopupButton, cancelButton: FullscreenHexagonPopup.PopupButton) {
        self.message = message
        self.acceptButton = acceptButton
        self.cancelButton = cancelButton
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(message)
                .font(Font.montserat(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, |104)
                .padding(.bottom, |54)

            HStack(spacing: 0) {
                acceptButton.asView()
                    .frame(maxWidth: .infinity)

                cancelButton.asView()
                    .frame(maxWidth: .infinity)
            }
            .overlay {
                Rectangle()
                    .fill(.white)
                    .opacity(0.13)
                    .frame(width: 1, height: |84)
            }
            .padding(.bottom, |136)
        }
        .multilineTextAlignment(.center)
        .minimumScaleFactor(0.7)
        .frame(maxWidth: .infinity)
        .background(.appPopupColour)
        .clipShape(HexagonShape(cornerRadius: 24))
        .padding(.horizontal, <->16)
    }

    struct PopupButton: Identifiable {
        let id: UUID = .init()
        let title: String
        let subtitle: String
        let action: () -> Void
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
            .fullscreenHexagonPopup(
                isPresented: .constant(true),
                message: "Do you want to discard changes?",
                acceptButton: .init(title: "Yes", subtitle: "Discard changes", action: { }),
                cancelButton: .init(title: "No", subtitle: "Keep Editing", action: { })
            )
    }
}

fileprivate extension FullscreenHexagonPopup.PopupButton {
    func asView() -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.action()
            }
        }) {
            VStack(spacing: 2) {
                Text(self.title)
                    .font(Font.montserat(size: 24, weight: .semibold))
                Text(self.subtitle)
                    .font(Font.montserat(size: 14, weight: .regular))
            }
            .foregroundStyle(.white)
        }
    }
}

struct FullscreenHexagonPopupModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let acceptButton: FullscreenHexagonPopup.PopupButton
    let cancelButton: FullscreenHexagonPopup.PopupButton

    func body(content: Content) -> some View {
        content
            .blur(radius: isPresented ? 6 : 0)
            .overlay {
                if isPresented {
                    FullscreenHexagonPopup(message: message, acceptButton: acceptButton, cancelButton: cancelButton)
                }
            }
    }
}

extension View {
    func fullscreenHexagonPopup(
        isPresented: Binding<Bool>,
        message: String,
        acceptButton: FullscreenHexagonPopup.PopupButton,
        cancelButton: FullscreenHexagonPopup.PopupButton
    ) -> some View {
        self.modifier(FullscreenHexagonPopupModifier(isPresented: isPresented, message: message, acceptButton: acceptButton, cancelButton: cancelButton))
    }
}

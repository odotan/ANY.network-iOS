import SwiftUI

struct PlainTextButton: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.custom(Font.montseratRegular, size: 14))
        }
        .buttonStyle(PlainTextButtonStyle())
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        PlainTextButton(text: "SKIP", action: { })
    }
}

struct PlainTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return PlainTextButtonView(config: configuration)
    }
}

struct PlainTextButtonView: View {
    let config: PlainTextButtonStyle.Configuration

    var body: some View {
        config.label
            .foregroundStyle(.appTransparentWhiteText)
            .brightness(config.isPressed ? -0.5 : 0)

            .frame(maxWidth: .infinity, maxHeight: 17)
    }
}

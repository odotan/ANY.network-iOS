import SwiftUI

struct HexagonButton: View {
    enum `Type` {
        case filled(Color), bordered
    }

    private let title: String
    private let type: `Type`
    private let action: () -> Void
    
    init(
        title: String,
        type: `Type` = .filled(.appPurple),
        action: @escaping () -> Void
    ) {
        self.title = title
        self.type = type
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)
                .frame(height: |54)
        }
        .hexagonButtonStyle(self.type)
    }

    @MainActor
    private var font: Font {
        switch type {
        case .filled:
            return Font.system(size: |16, weight: .bold)
        case .bordered:
            return Font.montserat(size: |18)
        }
    }
}

fileprivate extension Button {
    @ViewBuilder
    func hexagonButtonStyle(_ type: HexagonButton.`Type`) -> some View {
        switch type {
        case .bordered:
            self.buttonStyle(BorderedHexagonButtonStyle())
        case .filled(let color):
            self.buttonStyle(FilledHexagonButtonStyle(fillColor: color))
        }
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        VStack(spacing: 24) {
            HexagonButton(title: "Allow Contact Permissions", action: { })
            HexagonButton(title: "Connect More", type: .bordered, action: { })
            HexagonButton(title: "Connect Facebook", type: .filled(.appFacebookBlue) ,action: { })
            HexagonButton(title: "Connect WhatsApp", type: .filled(.appGreen), action: { })
            HexagonButton(title: "Delete", type: .filled(.appButtonDelete), action: { })
        }
    }
}

private struct BorderedHexagonButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return BorderedHexagonButtonView(config: configuration)
    }
}

private struct FilledHexagonButtonStyle: ButtonStyle {
    let fillColor: Color

    func makeBody(configuration: Configuration) -> some View {
        return FilledHexagonButtonView(config: configuration, fillColor: fillColor)
    }
}

private struct FilledHexagonButtonView: View {
    let config: FilledHexagonButtonStyle.Configuration
    let fillColor: Color

    var body: some View {
        config.label
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .background(background)
            .padding(.horizontal, <->16)
            .brightness(config.isPressed ? -0.2 : 0)
    }

    @ViewBuilder
    private var background: some View {
            RotatedHexagonShape(cornerRadius: 3)
                .fill(fillColor)
                .stroke(fillColor, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
    }
}

private struct BorderedHexagonButtonView: View {
    let config: BorderedHexagonButtonStyle.Configuration

    var body: some View {
        config.label
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .background(background)
            .padding(.horizontal, <->16)
            .brightness(config.isPressed ? -0.2 : 0)
    }

    @ViewBuilder
    private var background: some View {
        RotatedHexagonShape(cornerRadius: 3)
            .fill(.clear)
            .stroke(.appTransparentWhiteBorder, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
    }
}

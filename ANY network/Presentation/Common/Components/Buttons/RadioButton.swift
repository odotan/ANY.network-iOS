import SwiftUI

struct RadioButton: View {
    @Binding private var isActive: Bool
    private var text: String

    init(isActive: Binding<Bool>, text: String) {
        self._isActive = isActive
        self.text = text
    }

    var body: some View {
        HStack(spacing: <->14) {
            Button(action: { self.isActive.toggle() }) {
                RoundedRectangle(cornerRadius: <->6)
                    .stroke(.appRadioButtonBorder, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isActive ? .appGreen : .clear)
                            .padding(2)
                    )
#warning("Change radio button filled look when design is received")
            }
            .frame(width: <->17, height: |17)

            Text(text)
                .font(.custom(Font.montseratRegular, size: |14))
                .foregroundStyle(.appTransparentWhiteText)
        }
    }
}

#Preview {
    @State var isActive: Bool = true
    return ZStack {
        Color.appBackground.ignoresSafeArea()
        RadioButton(isActive: $isActive, text: "Allow me to Reset my account")
    }
}

import SwiftUI

struct HexagonTextField: View {
    @Binding private var text: String
    private var promt: String
    private var keyboardType: UIKeyboardType

    init(text: Binding<String>, promt: String, keyboardType: UIKeyboardType = .default) {
        self._text = text
        self.promt = promt
        self.keyboardType = keyboardType
    }

    var body: some View {
        TextField(
            "HexagonTextField",
            text: $text,
            prompt: Text(promt).foregroundStyle(.appTransparentWhiteText)
        )
        .textInputAutocapitalization(.never)
        .keyboardType(keyboardType)
        .font(.custom(Font.montseratRegular, size: 14))
        .foregroundStyle(.appTransparentWhiteText)
        .padding(.leading, 28)
        .padding(.vertical, 19)
        .frame(height: 54)
        .clipShape(RotatedHexagonShape(cornerRadius: 3))
        .background(
            RotatedHexagonShape(cornerRadius: 3)
                .fill(.appTransparentWhiteFill)
                .stroke(.appTransparentWhiteBorder, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
        )
        .padding(.horizontal, 16)
    }
}

#Preview {
    @State var text = ""
    return ZStack {
        Color.appBackground.ignoresSafeArea()
        HexagonTextField(text: $text, promt: "Email", keyboardType: .emailAddress)
    }
}

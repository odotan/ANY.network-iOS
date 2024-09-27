import SwiftUI

struct HexagonTextField: View {
    @Binding private var text: String
    private var promt: String
    private var deleteAction: (() -> Void)?
    private var keyboardType: UIKeyboardType

    init(
        text: Binding<String>,
        promt: String,
        deleteAction: (() -> Void)? = nil,
        keyboardType: UIKeyboardType = .default
    ) {
        self._text = text
        self.promt = promt
        self.deleteAction = deleteAction
        self.keyboardType = keyboardType
    }

    var body: some View {
        HStack {
            TextField(
                "HexagonTextField",
                text: $text,
                prompt: Text(promt).foregroundStyle(.appTransparentWhiteText)
            )
            .textInputAutocapitalization(.never)
            .keyboardType(keyboardType)
            .font(.montserat(size: |14))
            .foregroundStyle(.appTransparentWhiteText)
            .padding(.leading, 28)
            .padding(.trailing)
            .padding(.vertical, 19)
            .frame(height: 54)

            deleteButton
                .padding(.trailing, 22)
        }
        .background(
            RotatedHexagonShape(cornerRadius: 3)
                .fill(.appTransparentWhiteFill)
                .stroke(.appTransparentWhiteBorder, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
        )
        .background(.appBackground)
        .clipShape(RotatedHexagonShape(cornerRadius: 3))
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var deleteButton: some View {
        if let deleteAction {
            Button(action: deleteAction) {
                ZStack {
                    Circle()
                        .fill(.appOrange)
                        .frame(width: 20, height: 20)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white)
                        .frame(width: 8, height: 1)
                }
            }
        }
    }
}

#Preview {
    @State var text = ""
    return ZStack {
//        Color.appBackground.ignoresSafeArea()
        VStack(spacing: 24) {
            HexagonTextField(text: $text, promt: "Email", keyboardType: .emailAddress)
            HexagonTextField(text: $text, promt: "Email", deleteAction: { }, keyboardType: .emailAddress)
        }
    }
}

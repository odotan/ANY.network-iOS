import SwiftUI
import Combine

struct ContactInfoTextField: View {
    @Binding private var text: String
    private var promt: String
    @State private var fieldType: LabeledValueLabelType
    private var deleteAction: () -> Void
    private var onTypeChange: (LabeledValueLabelType) -> Void
    private var charLimit: Int

    private let types: [LabeledValueLabelType]

    init(
        text: Binding<String>,
        promt: String,
        fieldType: LabeledValueLabelType = .mobile,
        deleteAction: @escaping () -> Void,
        onTypeChange: @escaping (LabeledValueLabelType) -> Void
    ) {
        self._text = text
        self.promt = promt
        self.fieldType = fieldType
        self.deleteAction = deleteAction
        self.onTypeChange = onTypeChange
        self.charLimit = fieldType == .email ? 30 : 19

        types = LabeledValueLabelType.allCases.filter { $0 != .unknown && $0 != .address }
    }

    var body: some View {
        HStack(spacing: 14) {
            fieldTypeButton

            TextField(
                "HexagonTextField",
                text: $text,
                prompt: Text(promt).foregroundStyle(.appTransparentWhiteText)
            )
            .textInputAutocapitalization(.never)
            .keyboardType(fieldType.keyboardType)
            .submitLabel(.done)
            .font(Font.montserat(size: 14, weight: .regular))
            .foregroundStyle(.white)
            .padding(.vertical, 19)
            .padding(.horizontal)
            .frame(height: 54)
            .contentShape(Rectangle())

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
        .onChange(of: fieldType) { _, newValue in
            onTypeChange(newValue)
        }
    }

    private var fieldTypeButton: some View {
        Menu {
#warning("Placeholder menu until we get the design")
            ForEach(types, id: \.self) { type in
                Button(action: { self.fieldType = type }) {
                    Text(type.title)
                        .font(Font.montserat(size: 14, weight: .medium))
                        .foregroundStyle(.appGreen)
                        .minimumScaleFactor(0.7)
                }
            }
        } label: {
            HStack(spacing: 18) {
                Text(fieldType.title)
                    .font(Font.montserat(size: 14, weight: .medium))
                    .foregroundStyle(.appGreen)

                Image(.chevronRight)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 7, height: 14)
            }
            .frame(width: 110, height: 54)
            .background(
                RotatedHexagonShape(cornerRadius: 3)
                    .fill(.appTransparentWhiteFill)
                    .stroke(.appTransparentWhiteBorder, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
            )
            .contentShape(RotatedHexagonShape(cornerRadius: 3))
        }
    }

    private var deleteButton: some View {
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
        .zIndex(1)
    }
}

#Preview {
    @State var text = ""
    return ZStack {
//        Color.appBackground.ignoresSafeArea()
        VStack(spacing: 24) {
            ContactInfoTextField(text: $text,
                                 promt: "+56 903286 8274",
                                 fieldType: .mobile,
                                 deleteAction: {},
                                 onTypeChange: { _ in })
            ContactInfoTextField(text: $text,
                                 promt: "+56 903286 8274",
                                 fieldType: .phone,
                                 deleteAction: {},
                                 onTypeChange: { _ in })
            ContactInfoTextField(text: $text,
                                 promt: "hanson852@mail.com",
                                 fieldType: .email,
                                 deleteAction: {},
                                 onTypeChange: { _ in })
        }
    }
}

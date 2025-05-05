import SwiftUI
import Combine

struct ContactInfoTextField: View {
    @Binding private var text: String
    private var promt: String
    @State private var fieldType: any ContactInfoType
    private var deleteAction: () -> Void
    private var onTypeChange: (any ContactInfoType) -> Void
    private var charLimit: Int
    private var infoType: any ContactInfoType.Type

    init(
        text: Binding<String>,
        promt: String,
        fieldType: any ContactInfoType,
        deleteAction: @escaping () -> Void,
        onTypeChange: @escaping (any ContactInfoType) -> Void
    ) {
        self._text = text
        self.promt = promt
        self._fieldType = State(initialValue: fieldType)
        self.deleteAction = deleteAction
        self.onTypeChange = onTypeChange
        self.infoType = type(of: fieldType)
        self.charLimit = infoType is EmailAddressType.Type ? 30 : 19
    }

    var body: some View {
        HStack(spacing: 14) {
            fieldTypeButton(array: infoType.allCases)

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
    }

    @ViewBuilder
    private func fieldTypeButton(array: [any ContactInfoType]) -> some View {
        Menu {
            submenu(title: "Phone Number", values: PhoneNumberType.allCases, action: typeChanged)
            submenu(title: "Email", values: EmailAddressType.allCases, action: typeChanged)
            submenu(title: "Postal Address", values: PostalAddressType.allCases, action: typeChanged)
            submenu(title: "URL Address", values: URLAddressType.allCases, action: typeChanged)
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

    @ViewBuilder
    private func submenu<T: ContactInfoType>(title: String, values: [T], action: @escaping (T) -> Void) -> some View {
        Menu {
            ForEach(values, id: \.self) { type in
                Button(action: { withAnimation {action(type) } } ) {
                    Text(type.title)
                        .font(Font.montserat(size: 14, weight: .medium))
                        .minimumScaleFactor(0.7)
                }
            }
        } label: {
            Text(title)
                .font(Font.montserat(size: 14, weight: .medium))
                .minimumScaleFactor(0.7)
        }
    }

    @ViewBuilder
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

    func typeChanged<T: ContactInfoType>(type: T) {
        self.fieldType = type
        onTypeChange(type)
    }
}

#Preview {
    @State var text = ""
    return ZStack {
//        Color.appBackground.ignoresSafeArea()
        VStack(spacing: 24) {
            ContactInfoTextField(text: $text,
                                 promt: "+56 903286 8274",
                                 fieldType: PhoneNumberType.mobile,
                                 deleteAction: {},
                                 onTypeChange: { _ in })
            ContactInfoTextField(text: $text,
                                 promt: "+56 903286 8274",
                                 fieldType: PhoneNumberType.main,
                                 deleteAction: {},
                                 onTypeChange: { _ in })
            ContactInfoTextField(text: $text,
                                 promt: "hanson852@mail.com",
                                 fieldType: EmailAddressType.home,
                                 deleteAction: {},
                                 onTypeChange: { _ in })
        }
    }
}

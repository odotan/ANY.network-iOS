import SwiftUI

private struct SearchTextField: View {
    enum FocusField: Hashable {
        case search
    }

    @Binding private var text: String
    private let action: (() -> Void)?

    @FocusState var focusField: FocusField?

    init(text: Binding<String>, action: (() -> Void)?) {
        self._text = text
        self.action = action
        self.focusField = .search//nil
    }

    var body: some View {
        HStack {
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(.closeIcon)
                        .resizable()
                        .frame(width: <->14, height: |14)
                        .padding(5)
                        .background(.appLightGray)
                        .clipShape(.circle)
                        .padding(.leading, <->10)
                        .padding(.trailing, <->0)
                }
            } else {
                Image(.spyglass)
                    .resizable()
                    .frame(width: <->14, height: |14)
                    .padding(.leading, <->15)
                    .padding(.trailing, <->5)
            }

            TextField("Search", text: $text, prompt: Text("Type to search or add").foregroundStyle(.appLightGray))
                .focused($focusField, equals: .search)
                .submitLabel(.search)
                .frame(maxWidth: .infinity)
                .frame(height: |56)
                .overlay(alignment: .trailing) {
                    if let action = action {
                        Button(action: action) {
                            //                        Image(.greenPlus)
                            //                            .frame(width: <->24, height: |24)
                            
                            Text("Add")
                                .font(Font.montserat(size: 14, weight: .bold))
                                .foregroundStyle(.appGreen)
                        }
                        .padding(.trailing, <->15)
                    }
                }
                .foregroundStyle(.white)
                .font(Font.montserat(size: 20, weight: .semibold))
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.black.opacity(0.23))
        )
        .padding(.horizontal, <->16)
        .padding(.top, |19)
        .padding(.bottom, |16)
        .background(alignment: .top) {
            ZStack {
                Color.white.opacity(0.5)
                Rectangle()
                    .fill(.ultraThinMaterial)
            }
            .ignoresSafeArea()
            .clipShape(
                .rect(topLeadingRadius: 16, topTrailingRadius: 16)
            )
            .frame(height: 400)
        }
//        .onAppear {
//            self.focusField = .search
//        }
    }
}

#Preview {
    Color.appBackground
        .edgesIgnoringSafeArea(.all)
        .searchTextField(text: .constant(""), isSearching: .constant(true)) {  }
}

struct SearchTextFieldModifier: ViewModifier {
    @Binding var text: String
    @Binding var isSearching: Bool
    let action: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if isSearching {
                    SearchTextField(text: $text, action: action)
                }
            }
    }
}

extension View {
    func searchTextField(text: Binding<String>, isSearching: Binding<Bool>, action: (() -> Void)? = nil) -> some View {
        self.modifier(SearchTextFieldModifier(text: text, isSearching: isSearching, action: action))
    }
}

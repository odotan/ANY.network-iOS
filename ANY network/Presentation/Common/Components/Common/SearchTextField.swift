import SwiftUI

private struct SearchTextField: View {
    enum FocusField: Hashable {
        case search
    }

    @Binding private var text: String
    private let action: () -> Void

    @FocusState var focusField: FocusField?

    init(text: Binding<String>, action: @escaping () -> Void) {
        self._text = text
        self.action = action
    }

    var body: some View {
        HStack {
            Image(.spyglass)
                .resizable()
                .frame(width: <->14, height: |14)
                .padding(.leading, <->15)
                .padding(.trailing, <->5)

            TextField("Search", text: $text, prompt: Text(""))
                .focused($focusField, equals: .search)
                .submitLabel(.search)
                .frame(maxWidth: .infinity)
                .frame(height: |56)
                .overlay(alignment: .trailing) {
                    Button(action: action) {
                        Image(.greenPlus)
                            .frame(width: <->24, height: |24)
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
        .onAppear {
            focusField = .search
        }
    }
}

#Preview {
    Color.appBackground
        .edgesIgnoringSafeArea(.all)
        .searchTextField(text: .constant("asd")) {  }
}

struct SearchTextFieldModifier: ViewModifier {
    @Binding var text: String
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) {
                SearchTextField(text: $text, action: action)
            }
    }
}

extension View {
    func searchTextField(text: Binding<String>, action: @escaping () -> Void) -> some View {
        self.modifier(SearchTextFieldModifier(text: text, action: action))
    }
}

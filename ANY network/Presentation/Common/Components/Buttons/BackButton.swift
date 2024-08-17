import SwiftUI

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action, label: {
            Image(.backBtn)
                .padding(.top, |8)
                .padding(.bottom, |5)
                .padding(.horizontal)
        })
    }
}

struct BackButtonModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topLeading) {
                BackButton(action: action)
            }
    }
}

extension View {
    func backButton(action: @escaping (() -> Void)) -> some View {
        modifier(BackButtonModifier(action: action))
    }
}

#Preview {
    Color.blue.backButton {}
}

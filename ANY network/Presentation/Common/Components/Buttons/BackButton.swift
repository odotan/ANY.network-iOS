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
    let alignment: Alignment
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                BackButton(action: action)
            }
    }
}

extension View {
    func backButton(alignment: Alignment = .topLeading, action: @escaping (() -> Void)) -> some View {
//        modifier(BackButtonModifier(alignment: alignment, action: action))
        modifier(
            PillToolbarViewModifier(
                items: [.init(
                    icon: .back,
                    position: .leading,
                    action: action
                )],
                visible: true
            )
        )
    }
}

#Preview {
    Color.blue.backButton {}
}

import SwiftUI

@MainActor
private struct DetailsViewModifier<ViewContent>: ViewModifier where ViewContent : View {
    @Binding private var model: ContactPresentationModel?
    @State private var controller: UIHostingController<ViewContent>!
    private let content: () -> ViewContent

    init(model: Binding<ContactPresentationModel?>, @ViewBuilder content: @escaping () -> ViewContent) {
        self._model = model
        self.content = content
    }

    private func show() {
        controller = .init(rootView: content())
        guard let view = controller.view else { return }

        view.backgroundColor = .clear
        view.bounds = .init(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(view)

            let originalTransform = view.transform
            view.transform = view.transform.scaledBy(x: 0.2, y: 0.2)
            view.center = model?.anchor ?? window.center
            view.alpha = 0

            print("View.center", view.center)
            UIView.animate(withDuration: 0.35) {
                view.alpha = 1
                view.transform = originalTransform
                view.center.x = window.center.x
                view.center.y = window.center.y
            }
        }
    }

    private func dismiss(lastOrigin: CGPoint? = nil) {
        guard let view = controller.view else { return }
        UIView.animate(withDuration: 0.35) {
            view.transform = view.transform.scaledBy(x: 0.2, y: 0.2)
            view.center = lastOrigin ?? model?.anchor ?? view.center
            UIView.animate(withDuration: 0.2) {
                view.alpha = 0
            }
        } completion: { val in
            controller?.view.removeFromSuperview()
            controller = nil
        }
    }

    func body(content: Content) -> some View {
        ZStack {
            content
                .onChange(of: model) { oldValue, newValue in
                    if newValue != nil {
                        show()
                    } else {
                        dismiss(lastOrigin: oldValue?.anchor)
                    }
                }
        }
    }
}

extension View {
    @MainActor 
    func  contactDetails<Content>(model: Binding<ContactPresentationModel?>, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        self.modifier(DetailsViewModifier(model: model, content: content))
    }
}


import SwiftUI

private struct SimultaneousTrippleTapLayer: UIViewRepresentable {
    let onTrippleTap: () -> Void

    init(onTrippleTap: @escaping () -> Void) {
        self.onTrippleTap = onTrippleTap
    }

    func makeUIView(context: Context) -> some UIView {
        let view = ThreeFingerTapView(action: onTrippleTap)
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) { }
}

private class ThreeFingerTapView: UIView {
    var gesture: UITapGestureRecognizer!
    let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
        super.init(frame: .zero)
        setupTapGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    private func setupTapGesture() {
        gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gesture.numberOfTouchesRequired = 3
        addGestureRecognizer(gesture)
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        action()
    }
}

extension View {
    func simultaneousTrippleTapRecogniser(onTrippleTap: @escaping () -> Void) -> some View {
        overlay {
            SimultaneousTrippleTapLayer(onTrippleTap: onTrippleTap)
        }
    }
}

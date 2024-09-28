import SwiftUI

struct RecenterButton: View {
    private let action: (() -> Void)
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(.recenterIcon)
                .resizable()
                .frame(width: <->24, height: <->24)
        }
        .frame(width: <->48, height: <->48)
        .background {
            VisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
        }
        .clipShape(Circle())
        .shadow(radius: <->3)
    }
}

#Preview {
    RecenterButton() { }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .background {
            Color.appBackground
        }
}

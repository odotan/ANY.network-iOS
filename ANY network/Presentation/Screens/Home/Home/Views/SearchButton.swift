import SwiftUI

struct SearchButton: View {
    private let action: (() -> Void)
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(.spyglass)
                .resizable()
                .frame(width: <->18.05, height: <->18.05)
        }
        .frame(width: <->48, height: <->48)
        .background {
            Color.appBackground
                .overlay {
                    Color.appLightGray
                        .opacity(0.1)
                }
        }
        .clipShape(Circle())
    }
}

#Preview {
    SearchButton() { }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .background {
            Color.appBackground
        }
}

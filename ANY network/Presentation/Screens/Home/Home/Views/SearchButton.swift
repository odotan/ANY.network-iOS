import SwiftUI

struct SearchButton: View {
    private let action: (() -> Void)
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        #warning("Search button: In Progress")
        Button(action: action) {
            Image(.spyglass)
                .resizable()
                .frame(width: <->18.05, height: <->18.05)
        }
        .frame(width: <->48, height: <->48)
        .background {
            Color.appLightGray
                .opacity(1)
                .blur(radius: 3)
            
        }
        .clipShape(Circle())
    }
}

#Preview {
    SearchButton() { }
        .padding()
        .background {
            Color.appBackground
        }
}

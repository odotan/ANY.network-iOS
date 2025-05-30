import SwiftUI

struct TimerNumberView: View {
    let number: Int
    
    private var formattedNumber: String {
        String(format: "%02d", number)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(formattedNumber.enumerated()), id: \.offset) { _, char in
                Text(String(char))
            }
        }
    }
}

struct BounceTransition: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(y: isActive ? 0 : 20)
            .opacity(isActive ? 1 : 0)
    }
}

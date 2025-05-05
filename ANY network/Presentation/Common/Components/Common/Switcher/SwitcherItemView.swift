import SwiftUI

struct SwitcherItemView: View {
    var item: any ContactMethod
    
    var body: some View {
        topView
            .frame(width: <->28, height: |27.16) // Use the Exact Same Size
    }
    
    @ViewBuilder
    var topView: some View {
        Image(item.image)
            .resizable()
            .scaledToFit()
            .padding(3)
    }
}

#Preview {
    SwitcherItemView(item: Facebook(value: ""))
}

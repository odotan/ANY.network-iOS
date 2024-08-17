import SwiftUI

struct SwitcherItemView: View {
    var item: SwitcherItem
    
    var body: some View{
        topView
            .frame(width: <->28, height: |27.16) // Use the Exact Same Size
    }

    @ViewBuilder
    var topView: some View {
        if item.imageName != nil {
            Image(item.imageName!)
                .resizable()
                .scaledToFit()
                .padding(3)
                .background(Color.appBackground)

        } else {
            EmptyView()
        }
    }
}

#Preview {
    SwitcherItemView(item: .init(imageName: .phoneIcon))
}

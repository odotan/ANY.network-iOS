import SwiftUI

struct MyProfileView: View {
    @StateObject var viewModel: MyProfileViewModel

    var body: some View {
        Button(action: {
            viewModel.handle(.pop)
        }, label: {
            Text("POP")
        })
    }
}

#Preview {
    MyProfileView(viewModel: .init(coordinator: MainCoordinator()))
}

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        Button(action: {
            viewModel.handle(.goToProfile)
        }, label: {
            Text("MY Profile")
        })
        .onAppear {
            viewModel.handle(.getAllContacts)
        }
    }
}

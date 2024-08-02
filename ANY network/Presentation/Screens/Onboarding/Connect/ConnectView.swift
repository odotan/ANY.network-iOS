import SwiftUI

struct ConnectView: View {
    @StateObject var viewModel: ConnectViewModel
    
    var body: some View {
        Button {
            viewModel.handle(.goContactsPermission)
        } label: {
            Text("Get contacts access")
        }

    }
    
    private enum Constants {
        enum Strings {
            static let title = "Connect"
            static let description = "Press the hexagon to allow contacts permission"
        }
    }
}

#Preview {
    ConnectView(viewModel: .init(coordinator: OnboardingCoordinator(showMainFlowHandler: {  })))
}

import SwiftUI

struct ConnectNetworkConfirmationView: View {
    @StateObject var viewModel: ConnectNetworkConfirmationViewModel
    
    var title: String {
        viewModel.state.networkItem.title
    }

    var body: some View {
        VStack(spacing: 0) {
            NetworkLogoHexView(item: viewModel.state.networkItem, isConfirmation: true)
                .padding(.top, 24)
            
            Text("Congratulations!\nyour Signup is Successful.")
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.3)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .font(.montserat(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: <->300)
                .padding(.top, |26)
            
            Text("Lorem ipsum dolor sit amet, consetet sadipscing elitr, sed diam nonumy eirmod")
                .font(.montserat(size: 12, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, |14)

            Spacer()
                
            ToggleSwitch(isActive: isPublic, text: "Make this information available on my public Profile")
            
            ToggleSwitch(isActive: isSearchable, text: "Make this information publicly Searchable ")
                .padding(.top, |35)
            
            Spacer()
            
//            HexagonButton(title: "Go to my Contacts", type: .filled(viewModel.state.networkItem.backgroundColor)) {
//
//            }
//            .padding(.bottom, |20)
        }
        .padding(.horizontal, <->16)
        .frame(maxWidth: .infinity)
        .pillToolbar(items: [
            .init(icon: .customText("Connect"), position: .middle) {
                viewModel.handle(.connect)
            },
            .init(icon: .back, position: .leading) {
                viewModel.handle(.goBack)
            }
        ])
        .toolbar(.hidden)
        .background(.appBackground)
    }
    
    private var isSearchable: Binding<Bool> {
        .init(
            get: { viewModel.state.isSearchable },
            set: { viewModel.handle(.setIsSearchable($0)) }
        )
    }
    
    private var isPublic: Binding<Bool> {
        .init(
            get: { viewModel.state.isPublic },
            set: { viewModel.handle(.setIsPublic($0)) }
        )
    }
}

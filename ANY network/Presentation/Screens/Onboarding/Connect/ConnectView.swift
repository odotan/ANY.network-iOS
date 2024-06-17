import SwiftUI

struct ConnectView: View {
    @StateObject var viewModel: ConnectViewModel
    
    var body: some View {
        ConnectHexagonContainerView(focusHegaxonType: .contacts, isFocusItemVerified: .constant(false), focusPressed: {
            viewModel.handle(.goContactsPermission)
        })
            .background(Color.appBackground)
            .overlay {
                VStack(spacing: 29) {
                    Text(Constants.Strings.title)
                        .foregroundStyle(.white)
                        .font(.system(size: 24, weight: .bold))
                    
                    Text(Constants.Strings.description)
                        .foregroundStyle(.white.opacity(0.5))
                        .font(.system(size: 18, weight: .regular))
                    
                    Spacer()
                }
            }
            .backButton {
                viewModel.handle(.goBack)
            }
            .navigationBarHidden(true)
    }
    
    private enum Constants {
        enum Strings {
            static let title = "Connect"
            static let description = "Press the hexagon to begin"
        }
    }
}

#Preview {
    ConnectView(viewModel: .init(coordinator: OnboardingCoordinator(showMainFlowHandler: {  })))
}

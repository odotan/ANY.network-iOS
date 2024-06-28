import SwiftUI

struct ConnectView: View {
    @StateObject var viewModel: ConnectViewModel
    
    var body: some View {
        ConnectHexagonContainerView(isFocusItemVerified: .constant(false), focusPressed: {
            viewModel.handle(.goContactsPermission)
        }, selected: .contacts)
            .background(Color.appBackground)
            .overlay {
                VStack(spacing: |29) {
                    Text(Constants.Strings.title)
                        .foregroundStyle(.white)
                        .font(.system(size: |24, weight: .bold))
                    
                    Text(Constants.Strings.description)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.5))
                        .font(.system(size: |18, weight: .regular))
                        .padding(.horizontal)
                    
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
            static let description = "Press the hexagon to allow contacts permission"
        }
    }
}

#Preview {
    ConnectView(viewModel: .init(coordinator: OnboardingCoordinator(showMainFlowHandler: {  })))
}

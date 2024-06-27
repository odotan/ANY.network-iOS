import SwiftUI

struct AppCoordinatorView: View {
    private let screenFactory: ScreenFactory
    @ObservedObject private var coordinator: AppCoordinator
    
    init(screenFactory: ScreenFactory, coordinator: AppCoordinator) {
        self.screenFactory = screenFactory
        self.coordinator = coordinator
        
        coordinator.handle(.checkPermissions)
    }
    
    var body: some View {
        sceneView
//            .transition(.slide)
    }
    
    @ViewBuilder
    private var sceneView: some View {
        switch coordinator.state {
        case .idle:
            EmptyView()
        case .onboarding:
            OnboardingCoordinatorView(
                OnboardingCoordinator(showMainFlowHandler: { coordinator.handle(.showMain) }),
                factory: screenFactory
            )
        case .main:
            MainCoordinatorView(MainCoordinator(), factory: screenFactory)
        }
    }
}

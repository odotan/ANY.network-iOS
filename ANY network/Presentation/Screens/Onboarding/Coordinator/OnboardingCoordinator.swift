import Foundation

final class OnboardingCoordinator: Coordinator {
    
    enum Screen: Routable {
        case intro
    }
    
    private let showMainFlowHandler: () -> Void
    @Published var navigationPath = [Screen]()
    
    init(showMainFlowHandler: @escaping () -> Void) {
        self.showMainFlowHandler = showMainFlowHandler
    }
}

extension OnboardingCoordinator: OnboardingCoordinatorProtocol {
    func showMainFlow() {
        showMainFlowHandler()
    }
    
    func goBack() {
        navigationPath.removeLast()
    }

    func showIntro() {
        navigationPath.append(.intro)
    }
}

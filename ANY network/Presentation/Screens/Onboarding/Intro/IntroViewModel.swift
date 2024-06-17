import Foundation

final class IntroViewModel: ViewModel {
    @Published private(set) var state: State
    private let coordinator: OnboardingCoordinatorProtocol
    
    init(coordinator: OnboardingCoordinatorProtocol) {
        self.state = .idle
        self.coordinator = coordinator
    }
    
    func handle(_ event: Event) {
        switch event {
        case .next:
            coordinator.showConnect()
        }
    }
}

import Foundation

final class ConnectViewModel: ViewModel {
    @Published private(set) var state: State
    private let coordinator: OnboardingCoordinatorProtocol
    
    init(coordinator: OnboardingCoordinatorProtocol) {
        self.state = .idle
        self.coordinator = coordinator
    }
    
    func handle(_ event: Event) {
        switch event {
        case .goBack:
            coordinator.goBack()
        case .goContactsPermission:
            coordinator.showContactsPermission()
        }
    }
}

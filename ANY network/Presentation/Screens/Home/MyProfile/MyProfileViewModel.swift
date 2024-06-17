import Foundation

final class MyProfileViewModel: ViewModel {
    @Published private(set) var state: State
    private let coordinator: MainCoordinatorProtocol
    
    init(coordinator: MainCoordinatorProtocol) {
        self.state = .idle
        self.coordinator = coordinator
    }
    
    func handle(_ event: Event) {
        switch event {
        case .pop:
            coordinator.pop()
        }
    }
}

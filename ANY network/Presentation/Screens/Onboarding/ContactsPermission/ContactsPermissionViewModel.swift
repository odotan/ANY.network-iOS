import Foundation

final class ContactsPermissionViewModel: ViewModel {
    @Published private(set) var state: State
    private let coordinator: OnboardingCoordinatorProtocol
    
    private let getRequestAccessUseCase: GetRequestAccessUseCase

    init(coordinator: OnboardingCoordinatorProtocol, getRequestAccessUseCase: GetRequestAccessUseCase) {
        self.state = .idle
        self.coordinator = coordinator
        self.getRequestAccessUseCase = getRequestAccessUseCase
    }

    func handle(_ event: Event) {
        switch event {
        case .allow:
            Task { await allow() }
        case .skip:
            print("asda")
        case .goBack:
            coordinator.goBack()
        }
    }
}

extension ContactsPermissionViewModel {
    private func allow() async {
        do {
            try await getRequestAccessUseCase.requestAccess()
            coordinator.showMainFlow()
        } catch let error {
            print("Error", error.localizedDescription)
        }
    }
}


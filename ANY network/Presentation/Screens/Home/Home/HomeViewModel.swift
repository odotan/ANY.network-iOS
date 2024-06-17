import Foundation

final class HomeViewModel: ViewModel {
    @Published private(set) var state: State
    private let coordinator: MainCoordinatorProtocol
    private let getAllContactsUseCase: GetAllContactsUseCase
    
    init(coordinator: MainCoordinatorProtocol, getAllContactsUseCase: GetAllContactsUseCase) {
        self.state = .idle
        self.coordinator = coordinator
        self.getAllContactsUseCase = getAllContactsUseCase
    }
    
    func handle(_ event: Event) {
        switch event {
        case .goToProfile:
            coordinator.showMyProfile()
        case .getAllContacts:
            getAll()
        }
    }
}

extension HomeViewModel {
    private func getAll() {
        do {
            let all = try getAllContactsUseCase.execute()
            print(all)
        } catch let error {
            print("Error", error.localizedDescription)
        }
    }
}

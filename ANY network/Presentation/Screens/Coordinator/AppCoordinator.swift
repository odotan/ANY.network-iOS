import Foundation

final class AppCoordinator: ObservableObject {
    enum State {
        case idle
        case onboarding
        case main
    }
    
    enum Action {
        case checkPermissions
        case showOnboarding
        case showMain
    }

    
    @Published private(set) var state: State
    private let getContactsStatusUseCase: ContactsStatusUseCase

    init(getContactsStatusUseCase: ContactsStatusUseCase) {
        self.state = .idle
        self.getContactsStatusUseCase = getContactsStatusUseCase
    }
    
    func handle(_ action: Action) {
        switch action {
        case .checkPermissions:
            checkPermissions()
        case .showOnboarding:
            state = .onboarding
        case .showMain:
            state = .main
        }
    }
}

extension AppCoordinator {
    func checkPermissions() {
//        if case .notDetermined = getContactsStatusUseCase.status {
//            handle(.showOnboarding)
//        } else {
            handle(.showMain)
//        }
    }
}

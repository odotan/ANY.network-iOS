import Foundation

final class MainCoordinator: Coordinator {
    
    enum Screen: Routable {
        case home
        case myProfile
    }
    
    @Published var navigationPath = [Screen]()
}

extension MainCoordinator: MainCoordinatorProtocol {
    func showHome() {
        navigationPath.append(.home)
    }

    func showMyProfile() {
        navigationPath.append(.myProfile)
    }
    
    func pop() {
        navigationPath.removeLast()
    }
}

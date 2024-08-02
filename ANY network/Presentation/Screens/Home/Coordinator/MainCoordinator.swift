import Foundation

final class MainCoordinator: Coordinator {
    
    enum Screen: Routable {
        case home
        case myProfile
        case details(contact: Contact)
        case search
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
    
    func showDetails(for contact: Contact) {
        navigationPath.append(.details(contact: contact))
    }
    
    func showSearch() {
        navigationPath.append(.search)
    }
    
    func pop() {
        navigationPath.removeLast()
    }
}

import Foundation

final class MainCoordinator: Coordinator {
    
    enum Screen: Routable {
        case home
        case myProfile
        case details(contact: Contact, isNew: Bool)
        case search
    }
    
    @Published var navigationPath = [Screen]()
    @Published var isSearchPresented: Bool = false
}

extension MainCoordinator: MainCoordinatorProtocol {
    func showHome() {
        navigationPath.append(.home)
    }

    func showMyProfile() {
        navigationPath.append(.myProfile)
    }
    
    func showDetails(for contact: Contact, isNew: Bool) {
        navigationPath.append(.details(contact: contact, isNew: isNew))
    }
    
    func showSearch() {
//        navigationPath.append(.search)
        isSearchPresented = true
    }
    
    func pop() {
        navigationPath.removeLast()
    }
}

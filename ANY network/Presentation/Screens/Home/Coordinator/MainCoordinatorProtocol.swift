import Foundation

@MainActor
protocol MainCoordinatorProtocol {
    func showHome()
    func showMyProfile()
    func showDetails(for contact: Contact, isNew: Bool)
    func showSearch()
    func pop()
}

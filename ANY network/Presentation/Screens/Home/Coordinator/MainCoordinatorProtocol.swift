import Foundation

@MainActor
protocol MainCoordinatorProtocol {
    func showHome()
    func showMyProfile()
    func showDetails(for contact: Contact)
    func showSearch()
    func pop()
}

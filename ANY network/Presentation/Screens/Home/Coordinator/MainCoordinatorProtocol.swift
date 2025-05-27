import Foundation

@MainActor
protocol MainCoordinatorProtocol {
    func showHome()
    func showMyProfile(onDismiss: @escaping () -> Void)
    func showDetails(
        for contact: Contact,
        isNew: Bool,
        anchor: CGPoint?,
        onContactChangeEvent: @escaping (ContactChangeEvent) -> Void
    )
    func showSearch(onContactChangeEvent: @escaping (ContactChangeEvent) -> Void)
    func showConnect(contact: Contact)
    func showConnectSignUp(networkItem: NetworkItem, contact: Contact)
    func showConnectConfirmation(networkItem: NetworkItem)
    func pop()
    func pop(_ k: Int)
    func toggleFullscreen()
    func showRequestNetwork(contact: Contact)
    func showHiUHome()
}

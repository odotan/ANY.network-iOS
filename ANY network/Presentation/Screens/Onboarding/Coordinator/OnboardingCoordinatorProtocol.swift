import Foundation

@MainActor
protocol OnboardingCoordinatorProtocol {
    func showMainFlow()
    func goBack()
    func showIntro()
    func showConnect()
    func showContactsPermission()
}

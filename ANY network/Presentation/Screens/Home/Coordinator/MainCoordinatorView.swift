import SwiftUI

struct MainCoordinatorView: View {
    @Namespace var namespace

    private let factory: MainCoordinatorFactory
    @ObservedObject private var coordinator: MainCoordinator

    init(_ coordinator: MainCoordinator, factory: MainCoordinatorFactory) {
        self.factory = factory
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            factory.makeHiU(coordinator: coordinator)
                .navigationDestination(for: MainCoordinator.Screen.self) {
                    destination($0)
                }
                .fullScreenCover(
                    isPresented: $coordinator.isSearchPresented,
                    content: {
                        destination(.search(onContactChangeEvent: coordinator.onContactChangeEvent))
                    })
//                .contactDetails(model: $coordinator.selectedContact) {
//                    NavigationStack(path: $coordinator.detailsNavigationPath) {
//                        destination(
//                            .details(
//                                contact: coordinator.selectedContact!.contact,
//                                isNew: coordinator.selectedContact!.isNew,
//                                onContactChangeEvent: coordinator.selectedContact?.onContactChangeEvent ?? { _ in }
//                            )
//                        )
//                        .navigationDestination(for: MainCoordinator.Screen.self) {
//                            destination($0)
//                        }
//                    }
//                }
        }
        .ignoresSafeArea(edges: coordinator.isInFullscreen ? .all : [])
        .statusBar(hidden: coordinator.isInFullscreen)
        .sheet(item: $coordinator.sheetPresented) { destination($0) }
    }

    @ViewBuilder
    private func destination(_ screen: MainCoordinator.Screen) -> some View {
        switch screen {
        case .home:
            factory.makeHome(coordinator: coordinator)
        case .myProfile(let onDismiss):
            factory.makeMyProfile(coordinator: coordinator, onDismiss: onDismiss)
        case .details(let contact, let isNew, let onContactChangeEvent):
            factory.makeDetails(
                contact: contact,
                isNew: isNew,
                onContactChangeEvent: onContactChangeEvent,
                coordinator: coordinator
            )
//            .navigationTransition(.zoom(sourceID: contact.id, in: namespace))

        case .search(let onContactChangeEvent):
            factory.makeSearch(
                onContactChangeEvent: onContactChangeEvent,
                coordinator: coordinator
            )
        case .connect(let contact):
            factory.makeConnect(contact: contact, coordinator: coordinator)
        case .connectSignUp(let networkItem, let contact):
            factory.makeConnectNetworkSignUp(networkItem: networkItem, contact: contact, coordinator: coordinator)
        case .connectConfirmation(let networkItem):
            factory.makeConnectNetworkConfirmation(networkItem: networkItem, coordinator: coordinator)
        case .requestNetwork(let contact):
            factory.makeRequestNetwork(contact: contact, coordinator: coordinator)
        case .hiUHome:
            factory.makeHiU(coordinator: coordinator)
        }
    }
}

import Foundation
import SwiftUI

final class MainCoordinator: Coordinator {
    
    enum Screen: Routable {
        case home
        case myProfile(dismiss: () -> Void)
        case details(
            contact: Contact,
            isNew: Bool,
            onContactChangeEvent: (ContactChangeEvent) -> Void
        )
        case search(onContactChangeEvent: (ContactChangeEvent) -> Void)
        case connect(Contact)
        case connectSignUp(NetworkItem, Contact)
        case connectConfirmation(NetworkItem)
        case requestNetwork(Contact)
        case hiUHome
    }
    
    @Published var navigationPath = [Screen]()
    @Published var isSearchPresented: Bool = false
    @Published var selectedContact: ContactPresentationModel? = nil
    @Published var isInFullscreen: Bool = false
    @Published var sheetPresented: Screen?
    
    var onContactChangeEvent: (ContactChangeEvent) -> Void = { _ in }
}

extension MainCoordinator: MainCoordinatorProtocol {
    func toggleFullscreen() {
        isInFullscreen.toggle()
    }
    
    func showHome() {
        navigationPath.append(.home)
    }

    func showMyProfile(onDismiss: @escaping () -> Void) {
//        navigationPath.append(.myProfile)
        sheetPresented = .myProfile(dismiss: onDismiss)
    }
    
    func showDetails(
        for contact: Contact,
        isNew: Bool,
        anchor: CGPoint?,
        onContactChangeEvent: @escaping (ContactChangeEvent) -> Void
    ) {
        navigationPath.append(.details(contact: contact, isNew: isNew, onContactChangeEvent: onContactChangeEvent))
//        self.selectedContact = .init(
//            contact: contact,
//            isNew: isNew,
//            anchor: anchor,
//            onContactChangeEvent: onContactChangeEvent
//        )
    }
    
    func showSearch(onContactChangeEvent: @escaping (ContactChangeEvent) -> Void) {
        self.onContactChangeEvent = onContactChangeEvent
        isSearchPresented = true
    }
    
    func showConnect(contact: Contact) {
        navigationPath.append(.connect(contact))
    }
    
    func showConnectSignUp(networkItem: NetworkItem, contact: Contact) {
        navigationPath.append(.connectSignUp(networkItem, contact))
    }
    
    func showConnectConfirmation(networkItem: NetworkItem) {
        navigationPath.append(.connectConfirmation(networkItem))
    }
    
    func showRequestNetwork(contact: Contact) {
        navigationPath.append(.requestNetwork(contact))
    }

    func pop() {
        sheetPresented = nil

        guard selectedContact == nil else { // If we have a selected contact then there is nothing to remove from the nav path, so remove the contact and return
            selectedContact = nil
            return
        }
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }
    
    func pop(_ k: Int) {
        sheetPresented = nil

        guard selectedContact == nil else { // If we have a selected contact then there is nothing to remove from the nav path, so remove the contact and return
            selectedContact = nil
            return
        }
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast(k)
    }
    
    func showHiUHome() {
        navigationPath.append(.home)
    }
}

struct ContactPresentationModel {
    let contact: Contact
    let isNew: Bool
    let anchor: CGPoint? // Used for the origin point of the `zoom in and out` animation when opening a contact's details in the future
    let onContactChangeEvent: (ContactChangeEvent) -> Void
}

extension ContactPresentationModel: Equatable {
    static func == (lhs: ContactPresentationModel, rhs: ContactPresentationModel) -> Bool {
        lhs.contact.isLike(rhs.contact)
    }
}

extension MainCoordinator.Screen: Equatable {
    static func == (lhs: MainCoordinator.Screen, rhs: MainCoordinator.Screen) -> Bool {
        lhs.id == rhs.id
    }
}

extension MainCoordinator.Screen: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

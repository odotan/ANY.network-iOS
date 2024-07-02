import Foundation
import Contacts

final class ContactsService {
    private let store = CNContactStore()
}

extension ContactsService: ContactsAccessRepository {
    var status: ContactsServicesStatus {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        
        switch status {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }
    
    func requestAccess() async throws {
        try await store.requestAccess(for: .contacts)
    }
}

extension ContactsService: ContactsServicesRepository {
    func getAll() throws -> [Contact] {
        let containers = try store.containers(matching: nil)
                
        var all = [CNContact]()
        try containers.forEach { container in
            let predicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            all += contacts
        }

        return all.asContacts()
    }
    
    func getContact(withIdentifier identifier: String) throws -> Contact {
        let contact = try store.unifiedContact(withIdentifier: identifier, keysToFetch: keysToFetch)
        
        return contact.asContact()
    }
    
    func search(name: String) throws -> [Contact] {
        let predicate = CNContact.predicateForContacts(matchingName: name)
        let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        return contacts.asContacts()
    }
}

fileprivate let keysToFetch = [
    CNContactIdentifierKey as CNKeyDescriptor,
    CNContactGivenNameKey as CNKeyDescriptor,
    CNContactFamilyNameKey as CNKeyDescriptor,
    CNContactPhoneNumbersKey as CNKeyDescriptor,
    CNContactEmailAddressesKey as CNKeyDescriptor,
    CNContactImageDataKey as  CNKeyDescriptor,
    CNContactImageDataAvailableKey as CNKeyDescriptor
]

enum ContactsServicesStatus {
    case notDetermined
    case restricted
    case denied
    case authorized
}

extension CNContact: AnyContact {
    var id: String {
        identifier
    }
}

import Foundation
import Contacts

final class ContactsService: ContactsRepository {
    private let store = CNContactStore()
    
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
    
    func getAll() throws -> [Contact] {
        let containers = try store.containers(matching: nil)
        
        let keys = [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactImageDataKey as  CNKeyDescriptor,
            CNContactImageDataAvailableKey as CNKeyDescriptor
        ]
        
        var all = [CNContact]()
        try containers.forEach { container in
            let predicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keys)
            all += contacts
        }

        return all
    }
    
    func getContact(withIdentifier identifier: String) throws -> Contact {
        let keys = [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactImageDataKey as  CNKeyDescriptor,
            CNContactImageDataAvailableKey as CNKeyDescriptor
        ]

        let contact = try store.unifiedContact(withIdentifier: identifier, keysToFetch: keys)
        
        return contact
    }
}

enum ContactsServicesStatus {
    case notDetermined
    case restricted
    case denied
    case authorized
}

extension CNContact: Contact {
    var id: String {
        identifier
    }
}

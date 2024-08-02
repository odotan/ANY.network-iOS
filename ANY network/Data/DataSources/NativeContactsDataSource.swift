import Foundation
import Contacts

final class NativeContactsDataSource {
    private let store = CNContactStore()
}

extension NativeContactsDataSource {
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

    func getAll() async throws -> [CNContact] {
        let containers = try store.containers(matching: nil)
                
        var all = [CNContact]()
        try containers.forEach { container in
            let predicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            all += contacts
        }

        print("All", Thread.current, Task.currentPriority)

        return all.filter { $0.givenName != "" }.sorted(by: { $0.givenName < $1.givenName && !$1.givenName.isEmpty })
    }
    
    func getContact(withIdentifier identifier: String) throws -> CNContact? {
        let contact = try store.unifiedContact(withIdentifier: identifier, keysToFetch: keysToFetch)

        return contact
    }
    
    func search(name: String) throws -> [CNContact] {
        let predicate = CNContact.predicateForContacts(matchingName: name)
        let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        
        return contacts
    }
}

fileprivate let keysToFetch = [
    CNContactIdentifierKey as CNKeyDescriptor,
    CNContactNamePrefixKey as CNKeyDescriptor,
    CNContactGivenNameKey as CNKeyDescriptor,
    CNContactMiddleNameKey as CNKeyDescriptor,
    CNContactFamilyNameKey as CNKeyDescriptor,
    CNContactPreviousFamilyNameKey as CNKeyDescriptor,
    CNContactNameSuffixKey as CNKeyDescriptor,
    CNContactNicknameKey as CNKeyDescriptor,
    CNContactOrganizationNameKey as CNKeyDescriptor,
    CNContactDepartmentNameKey as CNKeyDescriptor,
    CNContactJobTitleKey as CNKeyDescriptor,
    CNContactPhoneticGivenNameKey as CNKeyDescriptor,
    CNContactPhoneticMiddleNameKey as CNKeyDescriptor,
    CNContactPhoneticFamilyNameKey as CNKeyDescriptor,
    CNContactPhoneticOrganizationNameKey as CNKeyDescriptor,
    CNContactBirthdayKey as CNKeyDescriptor,
    CNContactNonGregorianBirthdayKey as CNKeyDescriptor,
//    CNContactNoteKey as CNKeyDescriptor,
    CNContactImageDataKey as CNKeyDescriptor,
    CNContactThumbnailImageDataKey as CNKeyDescriptor,
    CNContactImageDataAvailableKey as CNKeyDescriptor,
    CNContactTypeKey as CNKeyDescriptor,
    CNContactPhoneNumbersKey as CNKeyDescriptor,
    CNContactEmailAddressesKey as CNKeyDescriptor,
    CNContactPostalAddressesKey as CNKeyDescriptor,
    CNContactDatesKey as CNKeyDescriptor,
    CNContactUrlAddressesKey as CNKeyDescriptor,
    CNContactRelationsKey as CNKeyDescriptor,
    CNContactSocialProfilesKey as CNKeyDescriptor,
    CNContactInstantMessageAddressesKey as CNKeyDescriptor
]

enum ContactsServicesStatus {
    case notDetermined
    case restricted
    case denied
    case authorized
}

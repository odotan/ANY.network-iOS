import Foundation
import Contacts

final class NativeContactsDataSource {
    private let store = CNContactStore()
}

extension NativeContactsDataSource {
    var status: NativeContactsServicesStatus {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        
        switch status {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .denied
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
    
    func create(contact contactT: Contact) async throws -> CNContact {
        let contact = CNMutableContact()
        
        if let givenName = contactT.givenName {
            contact.givenName = givenName
        }
        if let middleName = contactT.middleName {
            contact.middleName = middleName
        }
        if let familyName = contactT.familyName {
            contact.familyName = familyName
        }
        if let organizationName = contactT.organizationName {
            contact.organizationName = organizationName
        }
        contact.phoneNumbers = contactT.phoneNumbers.compactMap { CNLabeledValue(label: $0.label, value: CNPhoneNumber(stringValue: $0.value)) }
        contact.emailAddresses = contactT.emailAddresses.compactMap { CNLabeledValue(label: $0.label, value: NSString(string: $0.value)) }
//        contact.postalAddresses = contactT.postalAddresses.compactMap { CNLabeledValue(label: $0.label, value: CNPOstaladdress) }
        contact.urlAddresses = contactT.urlAddresses.compactMap { CNLabeledValue(label: $0.label, value: NSString(string: $0.value)) }
//        contact.socialProfiles = contactT.socialProfiles.compactMap { CNLabeledValue(label: $0.label, value: CNSocialProfile(urlString: <#T##String?#>, username: <#T##String?#>, userIdentifier: <#T##String?#>, service: <#T##String?#>)) }
//        contact.instantMessageAddresses = contactT.instantMessageAddresses.compactMap { CNLabeledValue(label: $0.label, value: CNInstantMessageAddress(username: <#T##String#>, service: <#T##String#>)) }
//        if let birthday = contactT.birthday {
//            contact.birthday = Da
//        }
        
        if let imageData = contactT.imageData {
            contact.imageData = imageData
        }
        
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)
        try store.execute(saveRequest)

        return contact
    }
    
    func update(contact contactT: Contact) async throws -> CNContact {
        guard let contactUnmodified = try getContact(withIdentifier: contactT.id) else { throw NativeError.missingContact }
        guard let mutableContact = contactUnmodified.mutableCopy() as? CNMutableContact else {
            throw NativeError.unknown }
        
        if let givenName = contactT.givenName {
            mutableContact.givenName = givenName
        }
        if let middleName = contactT.middleName {
            mutableContact.middleName = middleName
        }
        if let familyName = contactT.familyName {
            mutableContact.familyName = familyName
        }
        if let organizationName = contactT.organizationName {
            mutableContact.organizationName = organizationName
        }
        
        mutableContact.phoneNumbers = contactT.phoneNumbers.compactMap { CNLabeledValue(label: $0.label, value: CNPhoneNumber(stringValue: $0.value)) }
        mutableContact.emailAddresses = contactT.emailAddresses.compactMap { CNLabeledValue(label: $0.label, value: NSString(string: $0.value)) }
        mutableContact.urlAddresses = contactT.urlAddresses.compactMap { CNLabeledValue(label: $0.label, value: NSString(string: $0.value)) }
        
        let saveRequest = CNSaveRequest()
        saveRequest.update(mutableContact)

        try store.execute(saveRequest)
        
        return mutableContact
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

enum NativeContactsServicesStatus {
    case notDetermined
    case denied
    case authorized
}

enum NativeError: Error {
    case unknown
    case missingContact
}

extension Contact {
    var asCnContact: CNContact {
        let contact = CNMutableContact()
        
        if let givenName = givenName {
            contact.givenName = givenName
        }
        if let middleName = middleName {
            contact.middleName = middleName
        }
        if let familyName = familyName {
            contact.familyName = familyName
        }
        if let organizationName = organizationName {
            contact.organizationName = organizationName
        }
        contact.phoneNumbers = phoneNumbers.compactMap { CNLabeledValue(label: $0.label, value: CNPhoneNumber(stringValue: $0.value)) }
        contact.emailAddresses = emailAddresses.compactMap { CNLabeledValue(label: $0.label, value: NSString(string: $0.value)) }
//        contact.postalAddresses = contactT.postalAddresses.compactMap { CNLabeledValue(label: $0.label, value: CNPOstaladdress) }
        contact.urlAddresses = urlAddresses.compactMap { CNLabeledValue(label: $0.label, value: NSString(string: $0.value)) }
//        contact.socialProfiles = contactT.socialProfiles.compactMap { CNLabeledValue(label: $0.label, value: CNSocialProfile(urlString: <#T##String?#>, username: <#T##String?#>, userIdentifier: <#T##String?#>, service: <#T##String?#>)) }
//        contact.instantMessageAddresses = contactT.instantMessageAddresses.compactMap { CNLabeledValue(label: $0.label, value: CNInstantMessageAddress(username: <#T##String#>, service: <#T##String#>)) }
//        if let birthday = contactT.birthday {
//            contact.birthday = Da
//        }
        
        if let imageData = imageData {
            contact.imageData = imageData
        }
        
        return contact
    }
}

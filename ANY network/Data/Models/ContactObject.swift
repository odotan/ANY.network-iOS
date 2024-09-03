import Foundation
import RealmSwift

class ContactObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var isFavorite: Bool
    @Persisted var givenName: String?
    @Persisted var middleName: String?
    @Persisted var familyName: String?
    @Persisted var organizationName: String?
    @Persisted var phoneNumbers: List<LabeledValueObject>
    @Persisted var emailAddresses: List<LabeledValueObject>
    @Persisted var postalAddresses: List<LabeledValueObject>
    @Persisted var urlAddresses: List<LabeledValueObject>
    @Persisted var socialProfiles: List<LabeledValueObject>
    @Persisted var instantMessageAddresses: List<LabeledValueObject>
    @Persisted var birthday: Date?
    @Persisted var imageData: Data?
    @Persisted var imageDataAvailable: Bool
    
    convenience init(_ contact: Contact) {
        self.init()
        
        id = UUID().uuidString
        isFavorite = contact.isFavorite
        givenName = contact.givenName
        middleName = contact.middleName
        familyName = contact.familyName
        organizationName = contact.organizationName
        contact.phoneNumbers.forEach { phoneNumbers.append(LabeledValueObject($0)) }
        contact.emailAddresses.forEach { emailAddresses.append(LabeledValueObject($0)) }
        contact.postalAddresses.forEach { postalAddresses.append(LabeledValueObject($0)) }
        contact.urlAddresses.forEach { urlAddresses.append(LabeledValueObject($0)) }
        contact.socialProfiles.forEach { socialProfiles.append(LabeledValueObject($0)) }
        contact.instantMessageAddresses.forEach { instantMessageAddresses.append(LabeledValueObject($0)) }
        birthday = contact.birthday
        imageData = contact.imageData
        imageDataAvailable = contact.imageDataAvailable
    }
    
    func asContact() -> Contact {
        Contact(
            id: id,
            givenName: givenName,
            middleName: middleName,
            familyName: familyName,
            organizationName: organizationName,
            phoneNumbers: phoneNumbers.asLabeledValues(),
            emailAddresses: emailAddresses.asLabeledValues(),
            postalAddresses: postalAddresses.asLabeledValues(),
            urlAddresses: urlAddresses.asLabeledValues(),
            socialProfiles: socialProfiles.asLabeledValues(),
            instantMessageAddresses: instantMessageAddresses.asLabeledValues(),
            birthday: birthday,
            imageData: imageData,
            imageDataAvailable: imageDataAvailable,
            isFavorite: isFavorite
        )
    }
}

extension Results where Element: ContactObject {
    func asContact(sorted: Bool = true) -> [Contact] {
        let contacts = self.compactMap { $0.asContact() }
        if sorted {
            return Array(contacts).sort()
        }
        return Array(contacts)
    }
}

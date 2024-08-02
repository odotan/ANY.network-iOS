import Foundation
import Contacts

extension CNContact {
    func asContact() -> Contact {
        Contact(
            id: identifier,
            givenName: givenName,
            middleName: middleName,
            familyName: familyName,
            phoneNumbers: phoneNumbers.compactMap { $0.asLabeledValue() },
            emailAddresses: emailAddresses.compactMap { $0.asLabeledValue() },
            postalAddresses: postalAddresses.compactMap { $0.asLabeledValue() },
            urlAddresses: urlAddresses.compactMap { $0.asLabeledValue() },
            socialProfiles: socialProfiles.compactMap { $0.asLabeledValue() },
            instantMessageAddresses: instantMessageAddresses.compactMap { $0.asLabeledValue() },
            imageData: thumbnailImageData,//imageData,
            imageDataAvailable: imageDataAvailable,
            isFavorite: false
        )
    }
}

extension CNLabeledValue<CNPhoneNumber> {
    func asLabeledValue() -> LabeledValue {
        LabeledValue(id: identifier, label: label ?? "Various", value: value.stringValue)
    }
}

extension CNLabeledValue<NSString> {
    func asLabeledValue() -> LabeledValue {
        LabeledValue(id: identifier, label: label ?? "Various", value: String(value))
    }
}

extension CNLabeledValue<CNPostalAddress> {
    func asLabeledValue() -> LabeledValue {
        let formatter = CNPostalAddressFormatter()
        formatter.style = .mailingAddress
        let address = formatter.string(from: value)
        return LabeledValue(id: identifier, label: label ?? "Various", value: address)
    }
}

extension CNLabeledValue<CNSocialProfile> {
    func asLabeledValue() -> LabeledValue {
        LabeledValue(id: identifier, label: label ?? "Various", value: value.username)
    }
}

extension CNLabeledValue<CNInstantMessageAddress> {
    func asLabeledValue() -> LabeledValue {
        LabeledValue(id: identifier, label: label ?? "Various", value: value.username)
    }
}

extension Array where Element: CNContact {
    func asContacts(sorted: Bool = true) -> [Contact] {
        let contacts = self.compactMap { $0.asContact() }
        if sorted {
            return contacts.sort()
        }
        return contacts
    }
}

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
            emailAddresses: emailAddresses.compactMap { $0.asLabeledValue(for: EmailAddressType.self) },
            postalAddresses: postalAddresses.compactMap { $0.asLabeledValue() },
            urlAddresses: urlAddresses.compactMap { $0.asLabeledValue(for: URLAddressType.self) },
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
        let type = PhoneNumberType.getValue(label: label ?? CNLabelHome) ?? .other
        return LabeledValue(id: identifier, label: label ?? type.prompt, value: value.stringValue, infoType: type)
    }
}

extension CNLabeledValue<NSString> {
    func asLabeledValue(for type: any ContactInfoType.Type) -> LabeledValue {
        let specify = type.getValue(label: label ?? CNLabelHome)
        return LabeledValue(id: identifier, label: label ?? specify?.prompt ?? "Error", value: String(value), infoType: specify)
    }
}

extension CNLabeledValue<CNPostalAddress> {
    func asLabeledValue() -> LabeledValue {
        let formatter = CNPostalAddressFormatter()
        formatter.style = .mailingAddress
        let address = formatter.string(from: value)
        let type = PostalAddressType.getValue(label: label ?? CNLabelHome)
        return LabeledValue(id: identifier, label: label ?? type?.prompt ?? "Error", value: address, infoType: type)
    }
}

extension CNLabeledValue<CNSocialProfile> {
    func asLabeledValue() -> LabeledValue {
        LabeledValue(id: identifier, label: label ?? "Various", value: value.username, infoType: nil)
    }
}

extension CNLabeledValue<CNInstantMessageAddress> {
    func asLabeledValue() -> LabeledValue {
        LabeledValue(id: identifier, label: label ?? "Various", value: value.username, infoType: nil)
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

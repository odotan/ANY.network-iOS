import Foundation

struct Contact: Hashable, Equatable, Identifiable {
    let id: String
    var givenName: String?
    var middleName: String?
    var familyName: String?
    var organizationName: String?
    var phoneNumbers: [LabeledValue] = [LabeledValue]()
    var emailAddresses: [LabeledValue] = [LabeledValue]()
    var postalAddresses: [LabeledValue] = [LabeledValue]()
    var urlAddresses: [LabeledValue] = [LabeledValue]()
    var socialProfiles: [LabeledValue] = [LabeledValue]()
    var instantMessageAddresses: [LabeledValue] = [LabeledValue]()
    var birthday: Date?
    var imageData: Data?
    var imageDataAvailable: Bool = false
    var isFavorite: Bool = false
    var isMe: Bool = false
}

extension Contact {
    var abbreviation: String {
        var short = ""

        if let words = givenName?.components(separatedBy: " ") {
            if let first = words.first?.first {
                if words.count > 1, let last = words.last?.first {
                    short += String(first) + String(last)
                } else {
                    short += String(first)
                }
            }
        }

        if let second = familyName?.first {
            short += String(second)
        }

        return short
    }
    
    var fullName: String {
        var name = ""
        if givenName != nil && !givenName!.isEmpty || familyName != nil && !familyName!.isEmpty {
            name = "\(givenName ?? "") " + (familyName ?? "")
        } else {
            name = topNumber ?? ""
        }
        return name
    }
    
    var fullNameTwoLines: String {
        var name = givenName ?? ""
        
        if familyName != nil && !familyName!.isEmpty {
            name += "\n" + familyName!
        }

        return name
    }
    
    var topNumber: String? {
        return phoneNumbers.first?.value
    }

    func isLike(_ contact: Contact) -> Bool {
        id == contact.id &&
        givenName == contact.givenName &&
        middleName == contact.middleName &&
        familyName == contact.familyName &&
        organizationName == contact.organizationName &&
        phoneNumbers == contact.phoneNumbers &&
        emailAddresses == contact.emailAddresses &&
        postalAddresses == contact.postalAddresses &&
        urlAddresses == contact.urlAddresses &&
        socialProfiles == contact.socialProfiles &&
        instantMessageAddresses == contact.instantMessageAddresses &&
        birthday == contact.birthday &&
        imageData == contact.imageData &&
        imageDataAvailable == contact.imageDataAvailable &&
        isFavorite == contact.isFavorite
    }

    var allContactMethods: [ContactMethodType: [LabeledValue]] {
        return [
            .phoneNumbers: phoneNumbers,
            .emailAddresses: emailAddresses,
            .postalAddresses: postalAddresses,
            .urlAddresses: urlAddresses,
            .socialProfiles: socialProfiles,
            .instantMessageAddresses: instantMessageAddresses
        ]
    }
}

extension Array where Element == Contact {
    func sort() -> [Contact] {
        self.sorted {
            return $0.fullName.lowercased() < $1.fullName.lowercased()
        }
    }
}

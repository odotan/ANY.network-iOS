import Foundation

struct Contact: Hashable, Equatable, Identifiable {
    let id: String
    let givenName: String?
    let middleName: String?
    let familyName: String?
    var organizationName: String?
    var phoneNumbers: [LabeledValue]
    var emailAddresses: [LabeledValue]
    var postalAddresses: [LabeledValue]
    var urlAddresses: [LabeledValue]
    var socialProfiles: [LabeledValue]
    var instantMessageAddresses: [LabeledValue]
    var birthday: Date?
    let imageData: Data?
    let imageDataAvailable: Bool
    var isFavorite: Bool
}

extension Contact {
    var abbreviation: String {
        var short = ""
        if let first = givenName?.first {
            short += String(first)
        }
        if let second = familyName?.first {
            short += String(second)
        }

        return short
    }
    
    var fullName: String {
        return (givenName ?? "") + " " + (familyName ?? "")
    }
    
    var topNumber: String? {
        return phoneNumbers.first?.value
    }
}

extension Array where Element == Contact {
    func sort() -> [Contact] {
        self.sorted {
            if $0.familyName == nil { return false }
            if $1.familyName == nil { return false }

            return $0.familyName! < $1.familyName!
        }
    }
}

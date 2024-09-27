import Foundation
import SwiftUI

protocol ContactMethod: Identifiable, Equatable {
    var id: String { get }
    var value: String { get }
    var image: ImageResource { get }

    init(id: String, value: String)
}

enum ContactMethodType {
    case phoneNumbers
    case emailAddresses
    case postalAddresses
    case urlAddresses
    case socialProfiles
    case instantMessageAddresses
}

struct ContactMethodCreator {
    func getFirstMethodForAllTypes(using dict: [ContactMethodType: [LabeledValue]]) -> [any ContactMethod] {
        var createdSocialMedia: [String] = [] // A cache for checking which social media we have already created
        /// Separating social media from other contact methods since normaly we only create one of each `ContactMethodType`,
        /// but with social media and instant messaging we create 1 of each `Twitter`, `Facebook`, etc.
        var socialMedia = [(any ContactMethod)?]()

        let standardMethods: [any ContactMethod] = dict.keys.compactMap { type in
            switch type {
            case .socialProfiles, .instantMessageAddresses:
                guard let array = dict[type] else { return nil }
                array.forEach {
                    guard !createdSocialMedia.contains($0.label) else { return }
                    createdSocialMedia.append($0.label)
                    socialMedia.append(createContactMethod(ofType: type, value: $0))
                }
                return nil
            default:
                guard let value = dict[type]?.first else { return nil }
                return createContactMethod(ofType: type, value: value)
            }
        }

        return standardMethods + socialMedia.compactMap { $0 } // Add social media after removing any `nil`
    }

    func createContactMethods(ofType type: ContactMethodType, values: [LabeledValue]) -> [any ContactMethod] {
        guard !values.isEmpty else { return [] }
        return values.compactMap { createContactMethod(ofType: type, value: $0) }
    }

    func createContactMethod(ofType type: ContactMethodType, value: LabeledValue) -> (any ContactMethod)? {
        switch type {
        case .phoneNumbers:
            return PhoneNumber(id: value.id, value: value.value)
        case .emailAddresses:
            return EmailAddress(id: value.id, value: value.value)
        case .postalAddresses:
            return nil
        case .urlAddresses:
            return nil
        case .socialProfiles:
            return contactMethod(structName: value.label)?.init(id: value.id, value: value.value)
        case .instantMessageAddresses:
            return contactMethod(structName: value.label)?.init(id: value.id, value: value.value)
        }
    }

    private func contactMethod(structName: String) -> (any ContactMethod.Type)? {
        switch structName {
        case "Facebook":
            Facebook.self
        case "Twitter":
            Twitter.self
        case "Blackbery":
            Blackbery.self
        case "Telegram":
            Telegram.self
        case "Instagram":
            Instagram.self
        default:
            nil
        }
    }
}

extension ContactMethod {
    func asSwitcherItem() -> SwitcherItem {
        SwitcherItem(id: self.id, imageName: self.image)
    }
}

extension Array where Element == (any ContactMethod) {
    func contains(_ sequence: [any ContactMethod]) -> Bool {
        for item in sequence {
            if !self.contains(where: { $0.id == item.id }) { return false }
        }
        return true
    }
}

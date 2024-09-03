import Foundation
import Contacts
import SwiftUI

extension EditContactViewModel {
    enum Event {
        case update(Contact)
        case changeImageData(Data)

        case editGivenName(String)
        case editFamilyname(String)
        case editOrganizationName(String)

        case editContactMetod(id: String, newValue: LabeledValue)
        case deleteContactMetod(id: String, type: LabeledValueLabelType)

        case addPhoneNumber(LabeledValue)
        case addEmailAddress(LabeledValue)
        case addPostalAddress(LabeledValue)
        case addURLAddress(LabeledValue)
        case addSocialProfile(LabeledValue)
        case addInstantMessageAddress(LabeledValue)

        case editPhoneNumber(id: String, newValue: LabeledValue)
        case editEmailAddress(id: String, newValue: LabeledValue)
        case editPostalAddress(id: String, newValue: LabeledValue)
        case editURLAddress(id: String, newValue: LabeledValue)
        case editSocialProfile(id: String, newValue: LabeledValue)
        case editInstantMessageAddress(id: String, newValue: LabeledValue)

        case deletePhoneNumber(id: String)
        case deleteEmailAddress(id: String)
        case deletePostalAddress(id: String)
        case deleteURLAddress(id: String)
        case deleteSocialProfile(id: String)
        case deleteInstantMessageAddress(id: String)

        case setBirthday(Date)
        
        case checkIfIsModified
    }
}

enum LabeledValueLabelType: CaseIterable {
    case mobile
    case phone
    case email
    case url
    case address
    case unknown

    var value: String {
        switch self {
        case .mobile:
            return CNLabelPhoneNumberMobile
        case .phone:
            return CNLabelPhoneNumberMain
        case .email:
            return CNLabelEmailiCloud
        case .url:
            return CNLabelURLAddressHomePage
        case .address:
            return CNLabelHome
        case .unknown:
            return "Unknown"
        }
    }

    var title: String {
        switch self {
        case .mobile:
            return "Mobile"
        case .phone:
            return "Phone"
        case .email:
            return "E-mail"
        case .url:
            return "URL Address"
        case .address:
            return "Postal Address"
        case .unknown:
            return "Unknown"
        }
    }

    var keyboardType: UIKeyboardType {
        switch self {
        case .mobile, .phone:
            return .numberPad
        case .email:
            return .emailAddress
        case .url:
            return .URL
        case .address:
            return .default
        default:
            return .default
        }
    }
}

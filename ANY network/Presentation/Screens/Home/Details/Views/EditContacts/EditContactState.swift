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

        case editContactMetod(oldValue: LabeledValue, newValue: LabeledValue)
        case deleteContactMetod(id: String, type: any ContactInfoType)

        case addPhoneNumber(LabeledValue)
        case addEmailAddress(LabeledValue)
        case addPostalAddress(LabeledValue)
        case addURLAddress(LabeledValue)
        case addSocialProfile(LabeledValue)
        case addInstantMessageAddress(LabeledValue)

        case editPhoneNumber(newValue: LabeledValue)
        case editEmailAddress(newValue: LabeledValue)
        case editPostalAddress(newValue: LabeledValue)
        case editURLAddress(newValue: LabeledValue)
        case editSocialProfile(newValue: LabeledValue)
        case editInstantMessageAddress(newValue: LabeledValue)

        case deletePhoneNumber(id: String)
        case deleteEmailAddress(id: String)
        case deletePostalAddress(id: String)
        case deleteURLAddress(id: String)
        case deleteSocialProfile(id: String)
        case deleteInstantMessageAddress(id: String)

        case setBirthday(Date)
        
        case checkIfIsModified
        case showSection(DetailsViewModel.EditSection, Bool)
        case getSections
    }
}

enum LabeledValueClassification: CaseIterable {
    case phoneNumber
    case email
    case other
    case unknown
}

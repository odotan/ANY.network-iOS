import Foundation
import SwiftUI

final class EditContactViewModel: ObservableObject {
    @Binding var state: DetailsViewModel.State

    init(state: Binding<DetailsViewModel.State>) {
        self._state = state
    }

    func handle(_ event: EditContactViewModel.Event) {
        switch event {
        case .update(let contact):
            state.contact = contact
        case .changeImageData(let data):
            state.contact.imageData = data
        case .editGivenName(let string):
            state.contact.givenName = string
        case .editFamilyname(let string):
            state.contact.familyName = string
        case .editOrganizationName(let string):
            state.contact.organizationName = string
        case .editContactMetod(let oldValue, let newValue):
            contactMethodChanged(oldValue: oldValue, newValue: newValue)
        case .deleteContactMetod(let id, let type):
            deleteContactMethod(id: id, type: type)
        case .addPhoneNumber(let labeledValue):
            handle(.showSection(.contactInfo, true))
            state.contact.phoneNumbers.append(labeledValue)
        case .addEmailAddress(let labeledValue):
            handle(.showSection(.contactInfo, true))
            state.contact.emailAddresses.append(labeledValue)
        case .addPostalAddress(let labeledValue):
            handle(.showSection(.address, true))
            state.contact.postalAddresses.append(labeledValue)
        case .addURLAddress(let labeledValue):
            handle(.showSection(.contactInfo, true))
            state.contact.urlAddresses.append(labeledValue)
        case .addSocialProfile(let labeledValue):
            state.contact.socialProfiles.append(labeledValue)
        case .addInstantMessageAddress(let labeledValue):
            state.contact.instantMessageAddresses.append(labeledValue)
        case .editPhoneNumber(let newValue):
            replaceWithMatchingID(with: newValue, in: &state.contact.phoneNumbers)
        case .editEmailAddress(let newValue):
            replaceWithMatchingID(with: newValue, in: &state.contact.emailAddresses)
        case .editPostalAddress(let newValue):
            replaceWithMatchingID(with: newValue, in: &state.contact.postalAddresses)
        case .editURLAddress(let newValue):
            replaceWithMatchingID(with: newValue, in: &state.contact.urlAddresses)
        case .editSocialProfile(let newValue):
            replaceWithMatchingID(with: newValue, in: &state.contact.socialProfiles)
        case .editInstantMessageAddress(let newValue):
            replaceWithMatchingID(with: newValue, in: &state.contact.instantMessageAddresses)
        case .deletePhoneNumber(let id):
            removeElement(withId: id, from: &state.contact.phoneNumbers)
        case .deleteEmailAddress(let id):
            removeElement(withId: id, from: &state.contact.emailAddresses)
        case .deletePostalAddress(let id):
            removeElement(withId: id, from: &state.contact.postalAddresses)
        case .deleteURLAddress(let id):
            removeElement(withId: id, from: &state.contact.urlAddresses)
        case .deleteSocialProfile(let id):
            removeElement(withId: id, from: &state.contact.socialProfiles)
        case .deleteInstantMessageAddress(let id):
            removeElement(withId: id, from: &state.contact.instantMessageAddresses)
        case .setBirthday(let date):
            state.contact.birthday = date
        case .checkIfIsModified:
            state.initialContact
        case .showSection(let section, let shouldShow):
            if shouldShow {
                state.presentedSections.insert(section)
            } else {
                state.presentedSections.remove(section)
            }
        case .getSections:
            state.presentedSections = DetailsViewModel.EditSection.getSections(methods: state.contact.allContactMethods)
        }
    }
}

extension EditContactViewModel {
    private func replaceWithMatchingID(with newElement: LabeledValue, in array: inout [LabeledValue]) {
        guard let element = array.first(where: { $0.id == newElement.id }) else { return }
        array = array.replacing([element], with: [newElement])
    }

    private func removeElement(withId id: String, from array: inout [LabeledValue]) {
        array.removeAll(where: { $0.id == id })
    }

    private func editContactMethod(value: LabeledValue) {
        let type = value.infoType

        switch type {
        case is PhoneNumberType:
            handle(.editPhoneNumber(newValue: value))
        case is EmailAddressType:
            handle(.editEmailAddress(newValue: value))
        case is PostalAddressType:
            handle(.editPostalAddress(newValue: value))
        case is URLAddressType:
            handle(.editURLAddress(newValue: value))
        default:
            return
        }
    }

    private func deleteContactMethod(id: String, type: any ContactInfoType) {
        switch type {
        case is PhoneNumberType:
            handle(.deletePhoneNumber(id: id))
        case is EmailAddressType:
            handle(.deleteEmailAddress(id: id))
        case is PostalAddressType:
            handle(.deletePostalAddress(id: id))
        case is URLAddressType:
            handle(.deleteURLAddress(id: id))
        default:
            return
        }
    }

    private func contactMethodChanged(oldValue: LabeledValue, newValue: LabeledValue) {
        if oldValue.infoType?.prompt != newValue.infoType?.prompt {
            moveValue(value: newValue, oldType: oldValue.infoType)
        } else {
            editContactMethod(value: newValue)
        }
    }

    private func moveValue(value: LabeledValue, oldType: (any ContactInfoType)?) {
        remove(id: value.id, from: oldType)
        add(value: value, to: value.infoType)
    }

    private func remove(id: String, from type: (any ContactInfoType)?) {
        switch type?.prompt {
        case PhoneNumberType.home.prompt:
            removeElement(withId: id, from: &state.contact.phoneNumbers)
        case EmailAddressType.home.prompt:
            removeElement(withId: id, from: &state.contact.emailAddresses)
        case PostalAddressType.home.prompt:
            removeElement(withId: id, from: &state.contact.postalAddresses)
        case URLAddressType.home.prompt:
            removeElement(withId: id, from: &state.contact.urlAddresses)
        default:
            return
        }
    }

    private func add(value: LabeledValue, to type: (any ContactInfoType)?) {
        switch type?.prompt {
        case PhoneNumberType.home.prompt:
            handle(.addPhoneNumber(value))
        case EmailAddressType.home.prompt:
            handle(.addEmailAddress(value))
        case PostalAddressType.home.prompt:
            handle(.addPostalAddress(value))
        case URLAddressType.home.prompt:
            handle(.addURLAddress(value))
        default:
            return
        }
    }
}

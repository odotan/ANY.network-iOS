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
        case .editContactMetod(let id, let newValue):
            editContactMethod(id: id, value: newValue)
        case .deleteContactMetod(let id, let type):
            deleteContactMethod(id: id, type: type)
        case .addPhoneNumber(let labeledValue):
            state.contact.phoneNumbers.append(labeledValue)
        case .addEmailAddress(let labeledValue):
            state.contact.emailAddresses.append(labeledValue)
        case .addPostalAddress(let labeledValue):
            state.contact.postalAddresses.append(labeledValue)
        case .addURLAddress(let labeledValue):
            state.contact.urlAddresses.append(labeledValue)
        case .addSocialProfile(let labeledValue):
            state.contact.socialProfiles.append(labeledValue)
        case .addInstantMessageAddress(let labeledValue):
            state.contact.instantMessageAddresses.append(labeledValue)
        case .editPhoneNumber(let id, let newValue):
            replace(elementAtId: id, with: newValue, in: &state.contact.phoneNumbers)
        case .editEmailAddress(let id, let newValue):
            replace(elementAtId: id, with: newValue, in: &state.contact.emailAddresses)
        case .editPostalAddress(let id, let newValue):
            replace(elementAtId: id, with: newValue, in: &state.contact.postalAddresses)
        case .editURLAddress(let id, let newValue):
            replace(elementAtId: id, with: newValue, in: &state.contact.urlAddresses)
        case .editSocialProfile(let id, let newValue):
            replace(elementAtId: id, with: newValue, in: &state.contact.socialProfiles)
        case .editInstantMessageAddress(let id, let newValue):
            replace(elementAtId: id, with: newValue, in: &state.contact.instantMessageAddresses)
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
        }
    }
}

extension EditContactViewModel {
    private func replace(elementAtId id: String, with newElement: LabeledValue, in array: inout [LabeledValue]) {
        guard let element = array.first(where: { $0.id == id }) else { return }
        array = array.replacing([element], with: [newElement])
    }

    private func removeElement(withId id: String, from array: inout [LabeledValue]) {
        array.removeAll(where: { $0.id == id })
    }

    private func editContactMethod(id: String, value: LabeledValue) {
        let type = value.labelType
        switch type {
        case .phone, .mobile:
            handle(.editPhoneNumber(id: id, newValue: value))
        case .email:
            handle(.editEmailAddress(id: id, newValue: value))
        case .address:
            handle(.editPostalAddress(id: id, newValue: value))
        case .url:
            handle(.editURLAddress(id: id, newValue: value))
        default:
            return
        }
    }

    private func deleteContactMethod(id: String, type: LabeledValueLabelType) {
        switch type {
        case .phone, .mobile:
            handle(.deletePhoneNumber(id: id))
        case .email:
            handle(.deleteEmailAddress(id: id))
        case .address:
            handle(.deletePostalAddress(id: id))
        case .url:
            handle(.deleteURLAddress(id: id))
        default:
            return
        }
    }
}

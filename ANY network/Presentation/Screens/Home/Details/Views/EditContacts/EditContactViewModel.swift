import Foundation

final class EditContactViewModel: ViewModel {
    @Published private(set) var state: State
    private var contact: Contact

    init(contact: Contact) {
        self.state = State(
            id: contact.id,
            givenName: contact.givenName,
            middleName: contact.middleName,
            familyName: contact.familyName,
            organizationName: contact.organizationName,
            phoneNumbers: contact.phoneNumbers,
            emailAddresses: contact.emailAddresses,
            postalAddresses: contact.postalAddresses,
            urlAddresses: contact.urlAddresses,
            socialProfiles: contact.socialProfiles,
            instantMessageAddresses: contact.instantMessageAddresses,
            birthday: contact.birthday,
            imageData: contact.imageData,
            isFavorite: contact.isFavorite
        )
        self.contact = contact
    }

    func handle(_ event: Event) {
        switch event {
        case .changeImageData(let data):
            state.imageData = data
        case .editGivenName(let string):
            state.givenName = string
        case .editFamilyname(let string):
            state.familyName = string
        case .editOrganizationName(let string):
            state.organizationName = string
        case .editContactMetod(let id, let newValue):
            editContactMethod(id: id, value: newValue)
        case .deleteContactMetod(let id, let type):
            deleteContactMethod(id: id, type: type)
        case .addPhoneNumber(let labeledValue):
            state.phoneNumbers.append(labeledValue)
        case .addEmailAddress(let labeledValue):
            state.emailAddresses.append(labeledValue)
        case .addPostalAddress(let labeledValue):
            state.postalAddresses.append(labeledValue)
        case .addURLAddress(let labeledValue):
            state.urlAddresses.append(labeledValue)
        case .addSocialProfile(let labeledValue):
            state.socialProfiles.append(labeledValue)
        case .addInstantMessageAddress(let labeledValue):
            state.instantMessageAddresses.append(labeledValue)
        case .editPhoneNumber(let id, let newValue):
            replace(elementAtId: id, with: newValue, in: &state.phoneNumbers)
        case .editEmailAddress(let id, let newValue):
            replace(elementAtId: id, with: newValue, in: &state.emailAddresses)
        case .editPostalAddress(let id, let newValue):
            replace(elementAtId: id, with: newValue, in: &state.postalAddresses)
        case .editURLAddress(let id, let newValue):
            replace(elementAtId: id, with: newValue, in: &state.urlAddresses)
        case .editSocialProfile(let id, let newValue):
            replace(elementAtId: id, with: newValue, in: &state.socialProfiles)
        case .editInstantMessageAddress(let id, let newValue):
            replace(elementAtId: id, with: newValue, in: &state.instantMessageAddresses)
        case .deletePhoneNumber(let id):
            removeElement(withId: id, from: &state.phoneNumbers)
        case .deleteEmailAddress(let id):
            removeElement(withId: id, from: &state.emailAddresses)
        case .deletePostalAddress(let id):
            removeElement(withId: id, from: &state.postalAddresses)
        case .deleteURLAddress(let id):
            removeElement(withId: id, from: &state.urlAddresses)
        case .deleteSocialProfile(let id):
            removeElement(withId: id, from: &state.socialProfiles)
        case .deleteInstantMessageAddress(let id):
            removeElement(withId: id, from: &state.instantMessageAddresses)
        case .setBirthday(let date):
            state.birthday = date
        case .saveChanges:
            Task { await saveContact(contact) }
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

    private func saveContact(_ contact: Contact) async {
        do {
//            try await saveContactUseCase.execute(contact)
            print("Saving contact changes")
        } catch {
            print("Error:", error.localizedDescription)
        }
    }
}

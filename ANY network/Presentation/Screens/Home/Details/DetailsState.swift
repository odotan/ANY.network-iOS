import Foundation
import SwiftUI
import PhotosUI

extension DetailsViewModel {
    struct State: Equatable {
        var contact: Contact
        var isNew: Bool
        var initialContact: Contact
        var initialFavouriteCheckDone: Bool = false
        var contactImageData: Data?
        var selectedPhoto: PhotosPickerItem?
        var isFavorite: Bool = false
        var isEditing: Bool = false
        var actionPrompt: ActionPrompt? = nil
        var discardChanges: Bool = false
        var presentedSections: Set<EditSection> = []

        init(contact: Contact, isNew: Bool) {
            self.contact = contact
            self.isNew = isNew
            self.isEditing = isNew
            self.initialContact = contact
            self.contactImageData = contact.imageData
            self.presentedSections = EditSection.getSections(methods: contact.allContactMethods)
            if contact.organizationName != nil {
                self.presentedSections.insert(.company)
            }
        }

        var contactInfo: [LabeledValue] {
            contact.phoneNumbers + contact.emailAddresses + contact.urlAddresses
        }
    }
    
    enum Event {
        case goBack
        case showRequestNetwork
        case selectedPickerPhotoChanged(PhotosPickerItem?)
        case profileImageDataChanged(Data?)
        case performAction(any ContactAction)
        case presentPrompt(ActionPrompt?)
        case setIsEditing(Bool)
        case save
        case discardChanges(Bool)
        case deleteContact
        case interact(ContactInteraction)
    }
    
    enum Action {
        case phone
        case edit
        case email
        case favoriteToggle
    }
    
    struct ActionPrompt: Equatable {
        var id: String { title }
        let title: String
        let description: String
        let confirmText: String
        let cancelText: String = "Cancel"
        let confirmAction: (() -> Void)
        let confirmActionRole: ButtonRole?

        static func == (lhs: DetailsViewModel.ActionPrompt, rhs: DetailsViewModel.ActionPrompt) -> Bool {
            lhs.id == rhs.id
        }
    }

    enum EditSection: CaseIterable {
        case company, contactInfo, address, socialMedia

        var containsItemsOfType: [ContactMethodType] {
            switch self {
            case .company:
                return []
            case .contactInfo:
                return [.emailAddresses, .phoneNumbers, .urlAddresses]
            case .address:
                return [.postalAddresses]
            case .socialMedia:
                return [.instantMessageAddresses, .socialProfiles]
            }
        }

        var title: String {
            switch self {
            case .company:
                return "Comany"
            case .contactInfo:
                return "Contact Info"
            case .address:
                return "Address"
            case .socialMedia:
                return "Social Media"
            }
        }

        static func getSections(methods: [ContactMethodType: [LabeledValue]]) -> Set<EditSection> {
            let validMethods = methods
                .filter { !$0.value.isEmpty }
                .compactMap { value in EditSection.allCases.first { $0.containsItemsOfType.contains(value.key) } }
            return Set(validMethods)
        }
    }
}

import Foundation
import SwiftUI
import PhotosUI

extension DetailsViewModel {
    struct State: Equatable {
        var contact: Contact
        var isNew: Bool
        var initialContact: Contact
        var contactImageData: Data?
        var selectedPhoto: PhotosPickerItem?
        var isModified: Bool = false
        var isFavorite: Bool = false
        var isEditing: Bool = false
        var hasBeenModified: Bool = false
        var actionPrompt: ActionPrompt? = nil
        var discardChanges: Bool = false
        var presentedSections: Set<EditSection>

        init(contact: Contact, isNew: Bool) {
            self.contact = contact
            self.isNew = isNew
            self.isEditing = isNew
            self.initialContact = contact
            self.contactImageData = contact.imageData
            let methods = contact.allContactMethods
                .filter { !$0.value.isEmpty }
                .compactMap { value in EditSection.allCases.first { $0.containsItemsOfType.contains(value.key) } }
            self.presentedSections = Set(methods + (contact.organizationName != nil ? [.company] : []))
        }

        var contactInfo: [LabeledValue] {
            contact.phoneNumbers + contact.emailAddresses + contact.urlAddresses
        }
    }
    
    enum Event {
        case goBack
        case selectedPickerPhotoChanged(PhotosPickerItem?)
        case profileImageDataChanged(Data?)
        case performAction(any ContactAction)
        case presentPrompt(ActionPrompt?)
        case setIsEditing(Bool)
        case save
        case discardChanges(Bool)
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
        let action: (() -> Void)
        
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
    }
}

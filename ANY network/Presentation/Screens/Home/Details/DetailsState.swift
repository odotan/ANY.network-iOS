import Foundation
import SwiftUI
import PhotosUI

extension DetailsViewModel {
    struct State: Equatable {
        var contact: Contact
        var initialContact: Contact
        var contactImageData: Data?
        var selectedPhoto: PhotosPickerItem?
        var isModified: Bool = false
        var isFavorite: Bool = false
        var isEditing: Bool = false
        var hasBeenModified: Bool = false
        var actionPrompt: ActionPrompt? = nil
        var discardChanges: Bool = false
        
        init(contact: Contact) {
            self.contact = contact
            self.initialContact = contact
            self.contactImageData = contact.imageData
        }

        var contactInfo: [LabeledValue] {
            contact.phoneNumbers + contact.emailAddresses + contact.urlAddresses
        }
    }
    
    enum Event {
        case goBack
        case checkIfFavorite
        case starPressed
        case selectedPickerPhotoChanged(PhotosPickerItem?)
        case profileImageDataChanged(Data?)
        case performAction(Action)
        case presentPrompt(ActionPrompt?)
        case setIsEditing(Bool)
        case save
        case discardChanges(Bool)
    }
    
    enum Action {
        case phone
        case edit
        case email
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
}

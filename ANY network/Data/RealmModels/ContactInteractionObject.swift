import Foundation
import RealmSwift

class ContactInteractionObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var priority: Int
    @Persisted var contactId: String
    @Persisted var isNative: Bool
    @Persisted var interactionId: String
    @Persisted var date: Date = .now

    convenience init(interaction: ContactInteraction) {
        self.init()

        self.id = interaction.id
        self.contactId = interaction.contactId
        self.interactionId = interaction.interactionId
        self.priority = interaction.priority
        self.isNative = interaction.isNative
        self.date = interaction.date
    }
}

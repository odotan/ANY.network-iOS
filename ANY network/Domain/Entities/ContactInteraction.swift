import Foundation

struct ContactInteraction: Identifiable, Equatable, Hashable {
    let id: String
    var priority: Int
    let contactId: String
    let interactionId: String
    let isNative: Bool
    let date: Date

    init(
        id: String = UUID().uuidString,
        priority: Int,
        contactId: String,
        interactionId: String,
        isNative: Bool = true,
        date: Date = .now
    ) {
        self.id = id
        self.priority = priority
        self.contactId = contactId
        self.interactionId = interactionId
        self.isNative = isNative
        self.date = date
    }
    
    init(
        id: String = UUID().uuidString,
        contact: Contact,
        labeledValue: LabeledValue,
        priority: Int,
        isNative: Bool = true,
        date: Date = .now
    ) {
        self.id = id
        self.priority = priority
        self.contactId = contact.id
        self.interactionId = labeledValue.id
        self.isNative = isNative
        self.date = date
    }
    
    init(_ object: ContactInteractionObject) {
        self.id = object.id
        self.priority = object.priority
        self.contactId = object.contactId
        self.interactionId = object.interactionId
        self.isNative = object.isNative
        self.date = object.date
    }
}

struct ContactInteractionValueCreator {
    typealias Interaction = (contact: Contact, value: LabeledValue)
    
    func getInteractions(for interactions: [ContactInteraction], from contacts: [Contact]) throws -> [ContactInteraction: Interaction] {
        var dict = [ContactInteraction: Interaction]()
        for interaction in interactions {
            dict[interaction] = try getInteraction(for: interaction, from: contacts)
        }
        return dict
    }
    
    private func getLabeledValue(from contact: Contact?, id: String) -> LabeledValue? {
        contact?.allContactMethods
            .values
            .flatMap({ $0 })
            .first(where: { value in value.id == id })
    }

    func getInteraction(for interaction: ContactInteraction, from contacts: [Contact]) throws -> Interaction {
        guard let contact = contacts.first(where: { contact in contact.id == interaction.contactId }),
              let interaction = getLabeledValue(from: contact, id: interaction.interactionId) else {
            throw ContactInteractionValueCreatorError.contactOrValueNotFound
        }
        return (contact, interaction)
    }

    enum ContactInteractionValueCreatorError: Error {
        case contactOrValueNotFound
    }
}

extension Array where Element == ContactInteraction {
    func sort() -> [ContactInteraction] {
        self.sorted(by: { $0.priority < $1.priority })
    }
}

extension ContactInteraction {
    static let testInteraction = Self.init(id: "test", priority: 0, contactId: Contact.testContact.id, interactionId: Contact.testContact.phoneNumbers.first!.id, isNative: true, date: .now)
}

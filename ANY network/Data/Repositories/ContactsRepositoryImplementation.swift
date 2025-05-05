import Foundation

final class ContactsRepositoryImplementation {
    
    private var contacts: [Contact] = [Contact]()
    
    private let realmDataSource: RealmContactsDataSource
    private let nativeDataSource: NativeContactsDataSource
    
    private var all: [Contact]?
    private var allInteractions: [ContactInteraction]?

    init(realmDataSource: RealmContactsDataSource, nativeDataSource: NativeContactsDataSource) {
        self.realmDataSource = realmDataSource
        self.nativeDataSource = nativeDataSource
    }
}

extension ContactsRepositoryImplementation: ContactsRepository {
    @RealmActor
    func getStatus() async throws -> ContactServiceType {
        if let realmStatus = try await realmDataSource.getStatus(), realmStatus.realmActivated {
            return .realm
        }

        if nativeDataSource.status == .authorized {
            return .native
        }
        
        if nativeDataSource.status == .denied {
            return .realm
        }

        return .notDetermined
    }
    
    @RealmActor
    func update(status: ContactServiceType) async throws {
        guard status == .realm else { throw ContactRepositoryError.status }
        try await realmDataSource.update(status: true)
    }
    
    func requestAccess() async throws {
        try await nativeDataSource.requestAccess()
    }
    
    @RealmActor @discardableResult
    func getAll() async throws -> [Contact] {
        let status = try await getStatus()
        
        if let all = all, !all.isEmpty {
            return all
        }

        if status == .native {
            var allArray = try await nativeDataSource.getAll().asContacts()
            if let contact = try? await getIsMeContact(), let idx = allArray.firstIndex(where: { $0.id == contact.id }) {
                allArray[idx].isMe = true
            }
            all = allArray
        } else if let contacts = await realmDataSource.fetchContactList() {
            all = contacts.asContact()
        }

        return all ?? []
    }

    @RealmActor
    func getContact(withIdentifier identifier: String) async throws -> Contact? {
        let status = try await getStatus()

        if status == .native {
            return try nativeDataSource.getContact(withIdentifier: identifier)?.asContact()
        }

        return await realmDataSource.fetchContact(id: identifier)?.asContact()
    }
    
    /// Searches for `Contact` objects whose name contain the specified string
    @RealmActor
    func search(name: String) async throws -> [Contact] {
        let status = try await getStatus()
        
        if status == .native {
            return try nativeDataSource.search(name: name).compactMap { $0.asContact() }
        }

        return try await realmDataSource.search(name: name).compactMap { $0.asContact() }
    }

    /// Searches for `Contact` objects whose properties contain the specified string
    @RealmActor
    func search(term: String) async throws -> [Contact] {
        let status = try await getStatus()
        
        if status == .native {
            return try nativeDataSource.search(term: term).compactMap { $0.asContact() }
        }

        return try await realmDataSource.search(term: term).compactMap { $0.asContact() }
    }

    @RealmActor
    func getFavoriteContacts() async throws -> [Contact] {
        let status = try await getStatus()

        if status == .native {
            guard let favoriteIdsObjects = try await realmDataSource.getFavoritesForNative() else { return [] }

            var favoritesArray = [Contact]()
            for idObj in favoriteIdsObjects {
                let contact = try nativeDataSource.getContact(withIdentifier: idObj.nativeId)!.asContact()
                favoritesArray.append(contact)
            }
            
            return favoritesArray
        }
        
        guard let favoritesArray = try await realmDataSource.getFavorite() else { return [] }
        return favoritesArray.compactMap { $0.asContact() }
    }
    
    @RealmActor
    func getIsMeContact() async throws -> Contact? {
        let status = try await getStatus()

        if status == .native {
            guard let isMeNativeId = try await realmDataSource.getIsMeContactForNative() else { return nil }

            if let isMeNativeId = isMeNativeId.first?.nativeId {
                var contact = try nativeDataSource.getContact(withIdentifier: isMeNativeId)!.asContact()
                contact.isMe = true
                return contact
            }
        }
        
        guard let isMeArray = try await realmDataSource.getIsMeContact() else { return nil }
        return isMeArray.compactMap { $0.asContact() }.first
    }
    
    @RealmActor
    func setIsMe(contactId: String) async throws {
        let status = try await getStatus()
        defer {
            NotificationCenter.default.post(.favouritesChanged) // This will trigger the same events so its ok to be posted here as well
        }

        if status == .native {
            try await realmDataSource.setIsMeContact(forNativeId: contactId)
        } else {
            try await realmDataSource.setIsMeContact(forRealmId: contactId)
        }
    }
    
    @RealmActor
    func checkIfFavorite(contactId: String) async throws -> Bool {
        let status = try await getStatus()

        if status == .native {
            return try await realmDataSource.checkIfFavorite(forNativeId: contactId)
        } else {
            return try await realmDataSource.checkIfFavorite(forRealmId: contactId)
        }
    }
    
    @RealmActor
    func toggleFavorite(contactId: String) async throws -> Bool {
        let status = try await getStatus()
        defer {
            NotificationCenter.default.post(.favouritesChanged)
        }

        if status == .native {
            return try await realmDataSource.toggleFavorite(forNativeId: contactId)
        } else {
            return try await realmDataSource.toggleFavorite(forRealmId: contactId)
        }
    }
    
    @RealmActor
    func createEdit(contact: Contact) async throws -> Contact {
        var new: Contact!
        let status = try await getStatus()
        
        // Create Contact
        if contact.id.isEmpty {
            if status == .native {
                new = try await nativeDataSource.create(contact: contact).asContact()
            } else {
                new = try await realmDataSource.create(contact: contact).asContact()
            }
        } else { // Update Contact
            if status == .native {
                new = try await nativeDataSource.update(contact: contact).asContact()
            } else {
                new = try await realmDataSource.update(contact: contact).asContact()
            }
        }
        
        if let index = all?.firstIndex(where: { new.id == $0.id }) {
            all?[index] = new
        } else {
            all = nil
            try await getAll()
        }
        
        return new
    }

    @RealmActor
    func deleteContact(id: String) async throws {
        let status = try await getStatus()

        if case .native = status {
            try await nativeDataSource.deleteContact(id: id)
        } else if case .realm = status {
            await realmDataSource.deleteContact(id: id)
        } else {
            throw ContactRepositoryError.status
        }

        if let index = all?.firstIndex(where: { $0.id == id }) {
            all?.remove(at: index)
        } else {
            all = nil
            try await getAll()
        }
    }

    // MARK: - Interactions
    @RealmActor
    @discardableResult
    func fetchInteractions() async throws -> [ContactInteraction] {
        let status = try await getStatus()

        if status == .native {
            let interactionObjects = try await realmDataSource.fetchNativeInteractions()
            guard let interactionObjects else { return [] }
            
            let interactions: [ContactInteraction] = interactionObjects.compactMap { ContactInteraction($0) }.sort()
            allInteractions = interactions
            return interactions
        } else {
            let interactionObjects = try await realmDataSource.fetchRealmInteractions()
            guard let interactionObjects else { return [] }
            let interactions: [ContactInteraction] = interactionObjects.compactMap { ContactInteraction($0) }.sort()
            allInteractions = interactions
            return interactions
        }
    }

    @RealmActor
    func fetchInteraction(id: String) async throws -> ContactInteraction? {
        let status = try await getStatus()
        let interactionObject: ContactInteractionObject?

        if status == .native {
            interactionObject = try await realmDataSource.fetchNativeInteraction(id: id)
        } else {
            interactionObject = try await realmDataSource.fetchRealmInteraction(id: id)
        }
        
        guard let interactionObject else { return nil }
        return ContactInteraction(interactionObject)
    }

    @RealmActor
    func saveInteraction(interaction: ContactInteraction, type: InteractionActionType) async throws {
        let status = try await getStatus()
        let new: ContactInteraction!

        if allInteractions == nil {
            try await fetchInteractions()
        }
        
        if let allInteractions,
           let index = allInteractions
            .firstIndex(where: { $0.contactId == interaction.contactId && $0.interactionId == interaction.interactionId }) {
            // Update existing interaction.
            new = editExistingInteraction(existing: allInteractions[index], new: interaction, type: type)
        } else if let allInteractions { 
            // New interaction created.
            new = createNewInteraction(new: interaction, interactions: allInteractions)
        } else {
            // If we have no other interaction data save new as is.
            new = interaction
        }

        if status == .native {
            try await realmDataSource.saveNativeInteraction(ContactInteractionObject(interaction: new))
        } else {
            try await realmDataSource.saveRealmInteraction(ContactInteractionObject(interaction: new))
        }

        allInteractions = nil
        try await fetchInteractions()
    }
    
    @RealmActor
    private func editExistingInteraction(existing: ContactInteraction, new: ContactInteraction, type: InteractionActionType) -> ContactInteraction {
        if case .move = type { // If we are moving the interaction on the grid save the new priority
            return ContactInteraction(
                id: existing.id,
                priority: new.priority,
                contactId: new.contactId,
                interactionId: new.interactionId,
                isNative: existing.isNative,
                date: new.date
            )
        } else {
            // If we are interacting with an existing priority, check if the new priority is 0,
            // if it is we leave the old priority, since we are not moving the interaction.
            return ContactInteraction(
                id: existing.id,
                priority: new.priority == 0 ? existing.priority : new.priority,
                contactId: new.contactId,
                interactionId: new.interactionId,
                isNative: existing.isNative,
                date: new.date
            )
        }
    }
    
    @RealmActor
    private func createNewInteraction(new: ContactInteraction, interactions: [ContactInteraction]) -> ContactInteraction {
        return ContactInteraction(
            id: new.id,
            priority: new.priority,
            contactId: new.contactId,
            interactionId: new.interactionId,
            isNative: new.isNative,
            date: new.date
        )
    }
    
    private func findLowestFreePriority(interactions: [ContactInteraction]) -> Int {
        if let lowest = interactions.findLowestMissingPriority() {
           return lowest
        } else if let max = interactions.max(by: { $0.priority < $1.priority })?.priority {
            return (max + 1).isMultiple(of: 4) ? max + 2 : max + 1
        } else {
            return 0
        }
    }

    @RealmActor
    func deleteInteraction(id: String) async throws {
        let status = try await getStatus()

        if status == .native {
            try await realmDataSource.deleteNativeInteraction(id: id)
        } else {
            try await realmDataSource.deleteRealmInteraction(id: id)
        }
        
        allInteractions?.removeAll(where: { $0.id == id })
    }
    
    @RealmActor
    func checkIfRealmContainsContacts() async throws -> Bool {
        let status = try await getStatus()
        guard status != .notDetermined else { throw ContactRepositoryError.status }
        let contacts = await realmDataSource.fetchContactList()
        return !(contacts?.isEmpty ?? true)
    }
    
    @RealmActor
    func mergeRealmIntoNativeContacts() async throws {
        let status = try await getStatus()
        guard status == .native else { throw ContactRepositoryError.status }
        
        guard let realmContacts = await realmDataSource.fetchContactList()?.asContact() else {
            throw ContactRepositoryError.custom // Couldn't get contact list or list is empty
        }
        
        await withThrowingTaskGroup(of: Void.self) { tasks in
            for contact in realmContacts {
                tasks.addTask {
                    let _ = try await self.nativeDataSource.create(contact: contact)
                    await self.realmDataSource.deleteContact(id: contact.id)
                }
            }
        }
        
        try await getAll()
    }
}

enum ContactRepositoryError: Error {
    case status
    case custom
}

enum ContactServiceType: Codable {
    case notDetermined
    case native
    case realm
}

extension Notification.Name {
    static let ContactFavoritesChanged = Notification.Name("ContactFavoritesChanged")
}

extension Notification {
    static let favouritesChanged = Notification(name: .ContactFavoritesChanged)
}

import Foundation
import FirebaseFirestore

class FirebaseManager {
    private let db = Firestore.firestore()
    private let collectionName = "xmtpuser"

    // Store FUser in Firestore
    func storeXMTPUser(user: XMTPUser) async throws {
        // Check if address already exists
        let query = db
            .collection(collectionName)
            .whereField("address", isEqualTo: user.address)
        let snapshot = try await query.getDocuments()
        
        // Check if user exists
        guard snapshot.documents.isEmpty else { return }
        
        let data: [String: Any] = [
            "address": user.address,
            "inboxId": user.inboxId
        ]
        _ = try await db.collection(collectionName).addDocument(data: data)
    }

    // Retrieve all xmtpuser records
    func fetchAllXMTPUsers() async throws -> [XMTPUser] {
        let snapshot = try await db.collection(collectionName).getDocuments()
        let users = snapshot.documents.compactMap { doc -> XMTPUser? in
            let data = doc.data()
            guard let address = data["address"] as? String,
                  let inboxId = data["inboxId"] as? String else {
                return nil
            }
            return XMTPUser(address: address, inboxId: inboxId)
        }
        return users
    }

    // Delete all xmtpuser records (async/await version)
    func deleteAllXMTPUsers() async throws {
        let snapshot = try await db.collection(collectionName).getDocuments()
        let batch = db.batch()
        for document in snapshot.documents {
            batch.deleteDocument(document.reference)
        }
        try await batch.commit()
    }
}

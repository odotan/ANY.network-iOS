import Foundation
import FirebaseFirestore

class FirebaseManager {
    private let db = Firestore.firestore()
    private let collectionName = "xmtpuser"

    // Store FUser in Firestore (async/await version)
    func storeXMTPUser(user: XMTPUser) async throws {
        let data: [String: Any] = [
            "address": user.address,
            "inboxId": user.inboxId
        ]
        _ = try await db.collection(collectionName).addDocument(data: data)
    }

    // Retrieve all xmtpuser records (async/await version)
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
}

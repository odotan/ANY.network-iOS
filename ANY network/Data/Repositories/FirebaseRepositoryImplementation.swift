import Foundation

final class FirebaseRepositoryImplementation: FirebaseRepository {
    private let firebaseManager: FirebaseManager
    
    init(firebaseManager: FirebaseManager) {
        self.firebaseManager = firebaseManager
    }
    
    func storeXMTPUser(user: XMTPUser) async throws {
        try await firebaseManager.storeXMTPUser(user: user)
    }
    
    func fetchAllXMTPUsers() async throws -> [XMTPUser] {
        return try await firebaseManager.fetchAllXMTPUsers()
    }
} 

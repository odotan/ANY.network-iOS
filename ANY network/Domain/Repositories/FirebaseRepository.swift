import Foundation

protocol FirebaseRepository {
    func storeXMTPUser(user: XMTPUser) async throws
    func fetchAllXMTPUsers() async throws -> [XMTPUser]
} 

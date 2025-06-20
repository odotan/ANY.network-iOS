import Foundation

protocol XMTPRepository {
    func createClient() async throws
    func closeClient() async throws
    func isClientCreated() -> Bool
    func clearAllData()
} 
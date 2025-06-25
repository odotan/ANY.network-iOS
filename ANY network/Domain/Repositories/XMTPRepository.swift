import Foundation
import XMTPiOS

protocol XMTPRepository {
    func createClient() async throws -> Client
    func closeClient() async throws
    func isClientCreated() -> Bool
    func clearAllData()
    
    // MARK: - Conversation Methods
    func listConversations() async throws -> [Conversation]
    func listGroupConversations() async throws -> [Conversation]
    func listDMConversations() async throws -> [Conversation]
    
    // MARK: - Stream Methods
    func streamConversations(
        onConversation: @escaping (Conversation) -> Void,
        onError: @escaping (Error) -> Void
    ) async throws
    
    func streamAllMessages(
        onMessage: @escaping (DecodedMessage) -> Void,
        onError: @escaping (Error) -> Void
    ) async throws
    
    // MARK: - Conversation Management
    func getActiveConversations() async throws -> [Conversation]
    func getArchivedConversations() async throws -> [Conversation]
    
    // MARK: - Stream Control
    func stopStreams()

    // MARK: - Send Message
    func send(message: XMTPMessage) async throws
}

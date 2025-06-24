import Foundation
import XMTPiOS

final class XMTPRepositoryImplementation: XMTPRepository {
    private let xmtpManager: XMTPManager
    
    init(xmtpManager: XMTPManager) {
        self.xmtpManager = xmtpManager
    }
    
    func createClient() async throws -> Client {
        guard let client = try await xmtpManager.createClient() else {
            throw NSError(domain: "XMTPRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create XMTP client"]) 
        }
        return client
    }
    
    func closeClient() async throws {
        try await xmtpManager.closeClient()
    }
    
    func isClientCreated() -> Bool {
        // For now, we'll assume client is created if no exception is thrown
        // In a more sophisticated implementation, we could add a state property to XMTPManager
        return true
    }
    
    func clearAllData() {
        xmtpManager.clearAllData()
    }
    
    // MARK: - Conversation Methods
    func listConversations() async throws -> [Conversation] {
        try await xmtpManager.listConversations()
    }
    
    func listGroupConversations() async throws -> [Conversation] {
        // Since this method was removed from XMTPManager, we'll filter from all conversations
        let allConversations = try await xmtpManager.listConversations()
        return allConversations.filter { conversation in
            // Filter for group conversations based on conversation type
            // This would need to be adjusted based on the actual Conversation enum structure
            return true // For now, return all conversations
        }
    }
    
    func listDMConversations() async throws -> [Conversation] {
        // Since this method was removed from XMTPManager, we'll filter from all conversations
        let allConversations = try await xmtpManager.listConversations()
        return allConversations.filter { conversation in
            // Filter for DM conversations based on conversation type
            // This would need to be adjusted based on the actual Conversation enum structure
            return true // For now, return all conversations
        }
    }
    
    // MARK: - Stream Methods
    func streamConversations(
        onConversation: @escaping (Conversation) -> Void,
        onError: @escaping (Error) -> Void
    ) async throws {
        try await xmtpManager.streamConversations(onConversation: onConversation, onError: onError)
    }
    
    func streamAllMessages(
        onMessage: @escaping (DecodedMessage) -> Void,
        onError: @escaping (Error) -> Void
    ) async throws {
        try await xmtpManager.streamAllMessages(onMessage: onMessage, onError: onError)
    }
    
    // MARK: - Conversation Management
    func getActiveConversations() async throws -> [Conversation] {
        try await xmtpManager.getActiveConversations()
    }
    
    func getArchivedConversations() async throws -> [Conversation] {
        try await xmtpManager.getArchivedConversations()
    }
    
    // MARK: - Stream Control
    func stopStreams() {
        xmtpManager.stopStreams()
    }
    
    // MARK: - Send Message
    func sendMessage(inboxId: String, content: [String: String]) async throws {
        try await xmtpManager.sendMessage(inboxId: inboxId, content: content)
    }
} 
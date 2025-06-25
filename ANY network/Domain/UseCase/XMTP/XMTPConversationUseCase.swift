import Foundation
import XMTPiOS

final class XMTPConversationUseCase {
    private let xmtpRepository: XMTPRepository
    
    init(xmtpRepository: XMTPRepository) {
        self.xmtpRepository = xmtpRepository
    }
    
    // MARK: - List Conversations
    func listConversations() async throws -> [Conversation] {
        try await xmtpRepository.listConversations()
    }
    
    func listGroupConversations() async throws -> [Conversation] {
        try await xmtpRepository.listGroupConversations()
    }
    
    func listDMConversations() async throws -> [Conversation] {
        try await xmtpRepository.listDMConversations()
    }
    
    // MARK: - Stream Conversations
    func streamConversations(
        onConversation: @escaping (Conversation) -> Void,
        onError: @escaping (Error) -> Void
    ) async throws {
        try await xmtpRepository.streamConversations(onConversation: onConversation, onError: onError)
    }
    
    func streamAllMessages(
        onMessage: @escaping (DecodedMessage) -> Void,
        onError: @escaping (Error) -> Void
    ) async throws {
        try await xmtpRepository.streamAllMessages(onMessage: onMessage, onError: onError)
    }
    
    // MARK: - Conversation Management
    func getActiveConversations() async throws -> [Conversation] {
        try await xmtpRepository.getActiveConversations()
    }
    
    func getArchivedConversations() async throws -> [Conversation] {
        try await xmtpRepository.getArchivedConversations()
    }
    
    // MARK: - Stream Control
    func stopStreams() {
        xmtpRepository.stopStreams()
    }

    // MARK: - Send Message
    func send(message: XMTPMessage) async throws {
        try await xmtpRepository.send(message: message)
    }
} 

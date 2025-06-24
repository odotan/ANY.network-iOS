import Foundation
import XMTPiOS
import CryptoKit
#if canImport(SQLCipher)
import SQLCipher
#endif

final class XMTPManager {
    private var client: Client?
    private var conversationStream: AsyncThrowingStream<Conversation, Error>?
    private var messageStream: AsyncThrowingStream<DecodedMessage, Error>?

    func createClient() async throws -> Client? {
        print("🔐 [XMTPManager] Creating XMTP client...")
        
        #if canImport(SQLCipher)
        print("🔐 [XMTPManager] SQLCipher is available")
        #else
        print("🔐 [XMTPManager] Warning: SQLCipher is not available")
        #endif

        // Generate or retrieve database encryption key
        let keyBytes = getOrCreateDbEncryptionKey()

        let options = ClientOptions(
            api: .init(env: .dev, isSecure: false),
            dbEncryptionKey: keyBytes
        )
        
        let wallet = try SCWallet()
        client = try await Client.create(account: wallet, options: options)
        print("🔐 [XMTPManager] XMTP client created successfully!")
        return client
    }
    
    private func getOrCreateDbEncryptionKey() -> Data {
        if let existingKey = KeychainManager.shared.get(key: KeychainKey.xmtpDbEncryptionKey) as Data? {
            return existingKey
        }
        
        let newKey = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        KeychainManager.shared.save(key: KeychainKey.xmtpDbEncryptionKey, value: newKey)
        return newKey
    }
    
    func getClient() -> Client? {
        return client
    }
    
    func closeClient() async throws {
        print("🔐 [XMTPManager] Closing XMTP client...")
        // Stop any active streams
        conversationStream = nil
        messageStream = nil
        try await client?.deleteLocalDatabase()
        print("🔐 [XMTPManager] XMTP client closed and database deleted")
    }
    
    // Method to clear all XMTP data for testing
    func clearAllData() {
        KeychainManager.shared.delete(key: KeychainKey.xmtpKeys)
        KeychainManager.shared.delete(key: KeychainKey.xmtpDbEncryptionKey)
        print("🔐 [XMTPManager] Cleared all XMTP data from keychain")
    }

    // MARK: - Conversation Methods
    /// Check if identities are reachable on XMTP
    func canMessage(identities: [String]) async throws -> [String: Bool] {
        guard let client = client else {
            throw XMTPManagerError.dbEncryptionKeyNotFound
        }
        // Convert String addresses to PublicIdentity
        let publicIdentities = identities.map { address in
            PublicIdentity(kind: .ethereum, identifier: address)
        }
        return try await client.canMessage(identities: publicIdentities)
    }

    /// Create/Find a conversation by inboxId
    func findOrCreateConversation(inboxId: String) async throws -> Conversation {
        guard let client = client else {
            throw XMTPManagerError.dbEncryptionKeyNotFound
        }
        // Convert String addresses to PublicIdentity
        let publicId = PublicIdentity(kind: .ethereum, identifier: inboxId)
        if let conversation = try await client.conversations.findConversation(conversationId: publicId.identifier) {
            return conversation
        }

        return try await client.conversations.newConversation(with: publicId.identifier)
    }

    func sendMessage(inboxId: String, content: [String: String]) async throws {
        guard let client = client else {
            throw XMTPManagerError.dbEncryptionKeyNotFound
        }

        let conversation = try await findOrCreateConversation(inboxId: inboxId)

        let jsonData = try JSONSerialization.data(withJSONObject: content)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        try await conversation.prepareMessage(content: jsonString)
        print("!!! MESSAGE PREPARED !!!")
        try await conversation.publishMessages()
        print("!!! MESSAGE SENT !!!" )
    }
    
    // MARK: - Conversation Sync and Stream Methods
    
    /// List existing conversations
    /// - Returns: Array of conversations sorted by last message timestamp (descending)
    func listConversations() async throws -> [Conversation] {
        guard let client = client else {
            throw XMTPManagerError.clientNotInitialized
        }
        
        print("🔐 [XMTPManager] Listing conversations")
        return try await client.conversations.list()
    }
    
    /// Stream new conversations as they are created
    /// - Parameter onConversation: Closure called when a new conversation is received
    /// - Parameter onError: Closure called when an error occurs
    func streamConversations(
        onConversation: @escaping (Conversation) -> Void,
        onError: @escaping (Error) -> Void
    ) async throws {
        guard let client = client else {
            throw XMTPManagerError.clientNotInitialized
        }
        
        print("🔐 [XMTPManager] Starting conversation stream")
        
        conversationStream = try await client.conversations.stream()
        
        Task {
            do {
                for try await conversation in conversationStream! {
                    print("🔐 [XMTPManager] New conversation received: \(conversation.topic)")
                    onConversation(conversation)
                }
            } catch {
                print("🔐 [XMTPManager] Conversation stream error: \(error)")
                onError(error)
            }
        }
    }
    
    /// Stream all messages from all conversations
    /// - Parameter onMessage: Closure called when a new message is received
    /// - Parameter onError: Closure called when an error occurs
    func streamAllMessages(
        onMessage: @escaping (DecodedMessage) -> Void,
        onError: @escaping (Error) -> Void
    ) async throws {
        guard let client = client else {
            throw XMTPManagerError.clientNotInitialized
        }
        
        print("🔐 [XMTPManager] Starting message stream")
        
        messageStream = try await client.conversations.streamAllMessages()
        
        Task {
            do {
                for try await message in messageStream! {
                    print("🔐 [XMTPManager] New message received")
                    
                    // Handle unsupported content types
                    if let fallback = handleUnsupportedContentType(message) {
                        print("🔐 [XMTPManager] Using fallback for unsupported content: \(fallback)")
                    }
                    
                    onMessage(message)
                }
            } catch {
                print("🔐 [XMTPManager] Message stream error: \(error)")
                onError(error)
            }
        }
    }
    
    /// Stop all active streams
    func stopStreams() {
        print("🔐 [XMTPManager] Stopping all streams")
        conversationStream = nil
        messageStream = nil
    }
    
    /// Handle unsupported content types by returning fallback text if available
    /// - Parameter message: The decoded message to check
    /// - Returns: Fallback text if content type is not supported, nil otherwise
    private func handleUnsupportedContentType(_ message: DecodedMessage) -> String? {
        // For now, we'll return nil as the XMTP iOS SDK may handle this differently
        // This can be implemented based on the actual SDK capabilities
        return nil
    }
    
    /// Get active conversations for the current user
    /// - Returns: Array of active conversations
    func getActiveConversations() async throws -> [Conversation] {
        let allConversations = try await listConversations()
        return allConversations.filter { conversation in
            // Check if conversation is active based on available properties
            // This may need to be adjusted based on the actual Conversation type
            return true // For now, assume all conversations are active
        }
    }
    
    /// Get archived/inactive conversations for the current user
    /// - Returns: Array of inactive conversations
    func getArchivedConversations() async throws -> [Conversation] {
        let allConversations = try await listConversations()
        return allConversations.filter { conversation in
            // Check if conversation is inactive based on available properties
            // This may need to be adjusted based on the actual Conversation type
            return false // For now, assume no conversations are archived
        }
    }
}

enum XMTPManagerError: Error {
    case dbEncryptionKeyNotFound
    case clientNotInitialized
}

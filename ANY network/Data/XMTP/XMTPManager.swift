import Foundation
import XMTPiOS
import CryptoKit
#if canImport(SQLCipher)
import SQLCipher
#endif

final class XMTPManager {
    private var client: Client?

    func createClient() async throws {
        print("🔐 [XMTPManager] Creating XMTP client...")
        
        #if canImport(SQLCipher)
        print("🔐 [XMTPManager] SQLCipher is available")
        #else
        print("🔐 [XMTPManager] Warning: SQLCipher is not available")
        #endif

        // Generate or retrieve database encryption key
        let keyBytes = getOrCreateDbEncryptionKey()

        let options = ClientOptions(
            api: .init(env: .local, isSecure: false), // Try without SSL for local
            dbEncryptionKey: keyBytes
        )
        
        let wallet = try SCWallet()
        client = try await Client.create(account: wallet, options: options)
        print("🔐 [XMTPManager] XMTP client created successfully!")
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
        try await client?.deleteLocalDatabase()
        print("🔐 [XMTPManager] XMTP client closed and database deleted")
    }
    
    // Method to clear all XMTP data for testing
    func clearAllData() {
        KeychainManager.shared.delete(key: KeychainKey.xmtpKeys)
        KeychainManager.shared.delete(key: KeychainKey.xmtpDbEncryptionKey)
        print("🔐 [XMTPManager] Cleared all XMTP data from keychain")
    }
}

enum XMTPManagerError: Error {
    case dbEncryptionKeyNotFound
}

import Foundation
import XMTPiOS
import CryptoKit

final class XMTPManager {
    private var client: Client?

    func createClient() async throws {
        print("🔐 [XMTPManager] Creating XMTP client...")
        
        // Generate or retrieve database encryption key
        let keyBytes = getOrCreateDbEncryptionKey()
        print("🔐 [XMTPManager] Database encryption key ready (length: \(keyBytes.count) bytes)")

        let options = ClientOptions(
            api: .init(env: .local, isSecure: true),
            dbEncryptionKey: keyBytes
        )
        print("🔐 [XMTPManager] Client options configured")

        let wallet = try SCWallet()
        print("🔐 [XMTPManager] Wallet initialized, creating client...")
        
        client = try await Client.create(
            account: wallet,
            options: options
        )
        print("🔐 [XMTPManager] XMTP client created successfully!")
    }

    func closeClient() async throws {
        print("🔐 [XMTPManager] Closing XMTP client...")
        try await client?.deleteLocalDatabase()
        print("🔐 [XMTPManager] XMTP client closed and database deleted")
    }
    
    private func getOrCreateDbEncryptionKey() -> Data {
        if let existingKey = KeychainManager.shared.get(key: KeychainKey.xmtpDbEncryptionKey) as Data? {
            print("🔐 [XMTPManager] Found existing database encryption key in keychain")
            return existingKey
        } else {
            print("🔐 [XMTPManager] No existing database encryption key found, generating new one...")
            // Generate a new 32-byte encryption key
            var keyData = Data(count: 32)
            _ = keyData.withUnsafeMutableBytes { bytes in
                SecRandomCopyBytes(kSecRandomDefault, 32, bytes.baseAddress!)
            }
            KeychainManager.shared.save(key: KeychainKey.xmtpDbEncryptionKey, value: keyData)
            print("🔐 [XMTPManager] Generated and saved new database encryption key")
            return keyData
        }
    }
}

enum XMTPManagerError: Error {
    case dbEncryptionKeyNotFound
}
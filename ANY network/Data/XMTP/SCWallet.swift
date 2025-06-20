import Foundation
import XMTPiOS
import CryptoKit
#if canImport(SQLCipher)
import SQLCipher
#endif

public struct SCWallet: SigningKey {
    private let privateKey: PrivateKey
    
    public init() throws {
        print("🔑 [SCWallet] Initializing wallet...")
        
        // Try to restore existing key from keychain first
        if let existingKeyData = KeychainManager.shared.get(key: KeychainKey.xmtpKeys) as Data? {
            print("🔑 [SCWallet] Restoring existing wallet key...")
            do {
                self.privateKey = try PrivateKey(serializedData: existingKeyData)
                print("🔑 [SCWallet] Wallet restored. Address: \(privateKey.identity.identifier)")
            } catch {
                print("🔑 [SCWallet] Failed to restore key, generating new one...")
                self.privateKey = PrivateKey()
                let keyData = try privateKey.serializedData()
                KeychainManager.shared.save(key: KeychainKey.xmtpKeys, value: keyData)
                print("🔑 [SCWallet] New wallet created. Address: \(privateKey.identity.identifier)")
            }
        } else {
            print("🔑 [SCWallet] Generating new wallet key...")
            self.privateKey = PrivateKey()
            let keyData = try privateKey.serializedData()
            KeychainManager.shared.save(key: KeychainKey.xmtpKeys, value: keyData)
            print("🔑 [SCWallet] New wallet created. Address: \(privateKey.identity.identifier)")
        }
    }
    
    public var identity: PublicIdentity {
        return privateKey.identity
    }
    
    public var chainId: Int64? {
        return nil // Try without chain ID for local development
    }
 
    public var blockNumber: Int64? {
        return nil
    }
 
    public var type: SignerType { 
        return .SCW 
    }
    
    public func sign(_ message: String) async throws -> SignedData {
        let result = try await privateKey.sign(message)
        print("🔑 [SCWallet] Message signed successfully")
        return result
    }
    
    // Static method to clear wallet key (for testing)
    public static func clearWalletKey() {
        KeychainManager.shared.delete(key: KeychainKey.xmtpKeys)
        print("🔑 [SCWallet] Cleared wallet key from keychain")
    }
}

enum SCWalletError: Error {
    case addressMismatch
    case keyGenerationFailed
    case keyRestorationFailed
}

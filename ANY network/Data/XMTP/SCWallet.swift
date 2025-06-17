import Foundation
import XMTPiOS
import CryptoKit

public struct SCWallet: SigningKey {
    private let privateKey: PrivateKey
    
    public init() throws {
        print("🔑 [SCWallet] Initializing wallet...")
        
        // Try to load from keychain
        if let keyData = KeychainManager.shared.get(key: KeychainKey.xmtpKeys) as Data? {
            print("🔑 [SCWallet] Found existing wallet key in keychain, restoring...")
            self.privateKey = try PrivateKey.from(data: keyData)
            print("🔑 [SCWallet] Successfully restored wallet key. Address: \(privateKey.identity.identifier)")
        } else {
            print("🔑 [SCWallet] No existing wallet key found, generating new one...")
            // Generate new key and persist it
            let newKey = try PrivateKey.generate()
            let keyData = try newKey.serializedData()
            KeychainManager.shared.save(key: KeychainKey.xmtpKeys, value: keyData)
            print("🔑 [SCWallet] Generated and saved new wallet key. Address: \(newKey.identity.identifier)")
            self.privateKey = newKey
        }
    }
    
    public var identity: PublicIdentity {
        return privateKey.identity
    }
 
    public var chainId: Int64? {
        return 8453 // Base network
    }
 
    public var blockNumber: Int64? {
        return nil
    }
 
    public var type: SignerType { 
        return .SCW 
    }
 
    public func sign(_ message: String) async throws -> SignedData {
        print("🔑 [SCWallet] Signing message: \(message.prefix(20))...")
        let result = try await privateKey.sign(message)
        print("🔑 [SCWallet] Message signed successfully")
        return result
    }
}

enum SCWalletError: Error {
    case addressMismatch
    case keyGenerationFailed
    case keyRestorationFailed
}

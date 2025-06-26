import Foundation
import KeychainSwift

final class KeychainManager {
    static let shared = KeychainManager()

    private let keychain = KeychainSwift()

    private init() { }

    func save(key: String, value: String) {
        let keyString = key
        keychain.set(value, forKey: keyString)
        print("🔐 [KeychainManager] Saved string value for key: \(keyString)")
    }

    func get(key: String) -> String? {
        let keyString = key
        let result = keychain.get(keyString)
        if result != nil {
            print("🔐 [KeychainManager] Retrieved string value for key: \(keyString)")
        } else {
            print("🔐 [KeychainManager] No string value found for key: \(keyString)")
        }
        return result
    }
    
    func save(key: String, value: Data) {
        let keyString = key
        keychain.set(value, forKey: keyString)
        print("🔐 [KeychainManager] Saved data for key: \(keyString)")
    }

    func get(key: String) -> Data? {
        let keyString = key
        let result = keychain.getData(keyString)
        return result
    }
    
    func delete(key: String) {
        let keyString = key
        keychain.delete(keyString)
        print("🔐 [KeychainManager] Deleted key: \(keyString)")
    }
}

struct KeychainKey {
    static let xmtpKeys = "xmtpKeys"
    static let xmtpAddress = "xmtpAddress"
    static let xmtpDbEncryptionKey = "xmtpDbEncryptionKey"
}

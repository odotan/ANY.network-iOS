import Foundation
import Firebase
import FacebookCore
import FacebookLogin
import FirebaseCore
import FirebaseAuth
import CryptoKit

final class FacebookNetworkAuthentication {
    private let manager = LoginManager()
    
    @MainActor
    func signIn() async throws -> String {
        let nonce = try await facebookSignIn()

        guard let idToken = AuthenticationToken.current?.tokenString else {
            throw FacebookAuthError.missingFacebookToken
        }

        let credential = OAuthProvider.credential(providerID: .facebook, idToken: idToken, rawNonce: nonce, accessToken: nil)
                
        try await Auth.auth().signIn(with: credential)

        return ""
    }
    
    @MainActor
    private func facebookSignIn() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let nonce = randomNonceString()
            let currentNonce = sha256(nonce)
            let configuration = LoginConfiguration(permissions: ["public_profile"/*, "user_link"*/], tracking: .limited, nonce: currentNonce)
            manager.logIn(configuration: configuration) { result in
                switch result {
                case .failed(let error):
                    continuation.resume(throwing: error)
                case .cancelled:
                    continuation.resume(throwing: FacebookAuthError.userCancelled)
                case .success(let permissions, let declinedPermissions, let token):
//                    print("Perissions:", permissions, "\nDeclinedPermissions:", declinedPermissions, "\nToken:", token?.tokenString, "\n", Profile.current!.linkURL!.absoluteString, Profile.current?.name, "\n", Profile.current!.userID)
                    
                    continuation.resume(returning: nonce)
                }
            }
        }
    }

    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

enum FacebookAuthError: LocalizedError {
    case missingToken
    case userCancelled
    case missingFacebookToken
    
    var errorDescription: String? {
        switch self {
        case .missingToken:
            return "Missing Token"
        case .missingFacebookToken:
            return "Missing Facebook Token"
        case .userCancelled:
            return "User cancelled login"
        }
    }
}

import Foundation
import FirebaseAuth
import Firebase

final class SMSNetworkAuthentication {
    private let provider = PhoneAuthProvider.provider()
    private var verificationId: String?

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        try? signOut()
    }
    
    @MainActor
    func sendCode(to phone: String) async throws -> String {
        verificationId = try await provider.verifyPhoneNumber(phone)
        return verificationId ?? ""
    }
    
    func verifyCode(verificationCode: String) async throws {
        guard let verificationId = verificationId else {
            print("VerificationId is missing!")
            throw SMSError.missingVerificationId
        }

        let credential = provider.credential(withVerificationID: verificationId, verificationCode: verificationCode)
        try await Auth.auth().signIn(with: credential)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func userLoggedIN() -> User? {
        Auth.auth().currentUser
    }
}

enum SMSError: LocalizedError {
    case missingVerificationId
    
    var errorDescription: String? {
        switch self {
        case .missingVerificationId:
            return "Missing Verification Id"
        }
    }
}

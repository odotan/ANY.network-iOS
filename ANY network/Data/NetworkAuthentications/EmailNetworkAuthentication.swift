import Foundation
import FirebaseAuth
import Firebase

final class EmailNetworkAuthentication {
    private let actionCodeSettings = {
        let settings = ActionCodeSettings()
        settings.url = URL(string: "https://anynetwork.page.link")//"https://any.network/")
        settings.handleCodeInApp = true
        settings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        return settings
    }()
    private var email: String?
    
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        try? signOut()
    }
    
    func sendSignInLink(to email: String) async throws {
        try await Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings)
        self.email = email
    }
    
    func verifySignInLink(link: String) async throws -> String {
        guard let email = email else {
            throw EmailError.missingEmail
        }

        if Auth.auth().isSignIn(withEmailLink: link) {
            let response = try await Auth.auth().signIn(withEmail: email, link: link)
            return response.user.email ?? email
        }
        
        throw EmailError.unknown
    }
    
    private func signOut() throws {
        try Auth.auth().signOut()
    }
}

enum EmailError: LocalizedError {
    case missingEmail
    case unknown
    case missingLink
    
    var errorDescription: String? {
        switch self {
        case .missingEmail:
            return "Missing Email"
        case .unknown:
            return "Unknown Error"
        case .missingLink:
            return "Missing Link"
        }
    }
}

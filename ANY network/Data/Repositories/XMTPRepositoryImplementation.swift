import Foundation

final class XMTPRepositoryImplementation: XMTPRepository {
    private let xmtpManager: XMTPManager
    
    init(xmtpManager: XMTPManager) {
        self.xmtpManager = xmtpManager
    }
    
    func createClient() async throws {
        try await xmtpManager.createClient()
    }
    
    func closeClient() async throws {
        try await xmtpManager.closeClient()
    }
    
    func isClientCreated() -> Bool {
        // For now, we'll assume client is created if no exception is thrown
        // In a more sophisticated implementation, we could add a state property to XMTPManager
        return true
    }
    
    func clearAllData() {
        xmtpManager.clearAllData()
    }
} 
import Foundation
import XMTPiOS

final class CreateXMTPClientUseCase {
    private let xmtpRepository: XMTPRepository
    
    init(xmtpRepository: XMTPRepository) {
        self.xmtpRepository = xmtpRepository
    }
    
    func createClient() async throws -> Client {
        return try await xmtpRepository.createClient()
    }
    
    func closeClient() async throws {
        try await xmtpRepository.closeClient()
    }
    
    func isClientCreated() -> Bool {
        return xmtpRepository.isClientCreated()
    }
    
    func clearAllData() {
        xmtpRepository.clearAllData()
    }
} 
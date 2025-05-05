import Foundation

final class TelegramNetworkAuthentication {
    private let baseURL = "https://gatewayapi.telegram.org/"
    private let token = "AAE5EQAAVUstF9McmeEkOy2vbh3vjw-rPzflNDAC2C-TaA"
    //"AAEgEQAAbG4962HIu5TsTsrw_IEK27H-Si6VoAfQUeOhLQ" - Дани
    //"AAE5EQAAVUstF9McmeEkOy2vbh3vjw-rPzflNDAC2C-TaA" - OFIR's
    private var headers: [String: String] { [
        "Authorization": "Bearer \(self.token)",
        "Content-Type": "application/json"
    ] }
    
    private var requestId: String?

    func sendCode(to phone: String) async throws {
        guard let url = URL(string: baseURL + "sendVerificationMessage") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let params: [String : Any] = [
            "phone_number": phone,
            "code_length": 6,
            "ttl": 60,
            "payload": "",
            "callback_url": "https://any.network"
        ]
        print("!!! TELEGRAM AUTH: Send Code...")
        print("!!! Request Params: \(params)")
        request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
        print("!!! Response: \(jsonResponse)")

        if
            let ok = jsonResponse["ok"] as? Bool, ok,
            let result = jsonResponse["result"] as? [String: Any],
            let requestId = result["request_id"] as? String {
            self.requestId = requestId
        } else {
            let errorMessage = jsonResponse["error"] as? String ?? "Unknown error"
            throw NSError(domain: "APIError", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
    }
    
    func verify(code: String) async throws -> Bool {
        guard let url = URL(string: baseURL + "checkVerificationStatus") else {
            throw URLError(.badURL)
        }
        
        guard let requestId = requestId else {
            throw TelegramError.missingRequestId
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let params: [String : Any] = [
            "request_id": requestId,
            "code": code
        ]
        print("!!! TELEGRAM AUTH: Verifying Code...")
        print("!!! Request Params: \(params)")
        request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
  
        print("!!! Response: \(jsonResponse)")
        if let ok = jsonResponse["ok"] as? Bool, ok {
            return ok
        } else {
            let errorMessage = jsonResponse["error"] as? String ?? "Unknown error"
            throw NSError(domain: "APIError", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
    }
}

enum TelegramError: LocalizedError {
    case missingRequestId
    
    var errorDescription: String? {
        switch self {
        case .missingRequestId:
            return "Missing Request Id"
        }
    }
}

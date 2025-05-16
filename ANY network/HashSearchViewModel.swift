import Foundation
import CryptoKit
import Combine

enum Sorting {
    case prefix
    case symbols
    case literal
    
    var title: String {
        switch self {
        case .prefix:
            "prefix"
        case .symbols:
            "h,i,u"
        case .literal:
            "hiu"
        }
    }
}

class HashSearchViewModel: ObservableObject {
    @Published var message = "Hello world"
    @Published var requirement = "Hiu"
    @Published var numberOfHashesString: String = "10"
    @Published var isBase64: Bool = true
    var numberOfHashes: Int {
        Int(numberOfHashesString ?? "0")!
    }
    @Published var results: [HashResult] = []
    @Published var sorting: Sorting = .prefix

    @Published var isRunning = false
    @Published var totalHashes = 0
    @Published var instantSpeed: Double = 0
    @Published var averageSpeed: Double = 0
    @Published var estimatedRequired = 0
    
    @Published var actionSheet: Bool = false

    private var startTime: Date = .now
    private var lastFoundTime: Date = .now
    private var timer: Timer?
    private var task: Task<Void, Never>?
    
    func start() {
        guard !message.isEmpty && !requirement.isEmpty else { return }

        isRunning = true
        results = []
        totalHashes = 0
        startTime = Date()
        lastFoundTime = Date()

        task = Task.detached(priority: .userInitiated) {
            await self.performHashSearch()
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let elapsed = Date().timeIntervalSince(self.lastFoundTime)
            self.instantSpeed = Double(self.totalHashes) / max(elapsed, 0.001)

            let totalElapsed = Date().timeIntervalSince(self.startTime)
            self.averageSpeed = Double(self.totalHashes) / max(totalElapsed, 0.001)

            let probability = 1.0 / pow(self.isBase64 ? 64.0 : 16.0, Double(self.requirement.count)) // base64 space
            self.estimatedRequired = Int(1.0 / probability)
        }
    }

    func stop() {
        isRunning = false
        task?.cancel()
        timer?.invalidate()
    }

    private func sha256Base64(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        
        if isBase64 {
            return Data(hash).base64EncodedString()
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    private func matchRequirement(_ hash: String) -> Bool {
        let hashSet = Set(hash.lowercased())
        let reqSet = Set(requirement.lowercased())

        switch sorting {
        case .prefix:
            return hash.lowercased().hasPrefix(requirement.lowercased())
        case .literal:
            return hash.lowercased().contains(requirement.lowercased())
        case .symbols:
            return reqSet.isSubset(of: hashSet)
        }
    }

    private func performHashSearch() async {
        let initialHash = sha256Base64(message)


        var localNonce = 1
        var localTotalHashes = 0

        while isRunning {

//            // Check if we've found enough results
//            let foundEnough = await MainActor.run {
//                results.count >= numberOfHashes
//            }
            let foundEnough = results.count >= numberOfHashes
            
            if foundEnough { break }

            let combined = initialHash + String(localNonce)
            let newHash = sha256Base64(combined)
            localTotalHashes += 1

            if matchRequirement(newHash) {
                await MainActor.run {
                    let timeElapsed = Date().timeIntervalSince(startTime)

                    self.results.append(HashResult(nonce: localNonce, hash: newHash, timeElapsed: timeElapsed))
                    self.lastFoundTime = Date()
                    self.totalHashes = localTotalHashes
                }
            }

//            await MainActor.run {
//                self.totalHashes = localTotalHashes
//            }

            localNonce += 1
        }

        await MainActor.run {
            self.stop()
        }
    }
}

struct HashResult: Hashable, Identifiable {
    let nonce: Int
    let hash: String
    let timeElapsed: TimeInterval  // in seconds (includes milliseconds)

    var id: String {
        hash
    }
}

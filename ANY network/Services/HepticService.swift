import Foundation
import CoreHaptics

class HepticService {
    static let shared = HepticService()

    private var engine: CHHapticEngine?
    
    init() {
        try? start()
    }
    
    func start() throws {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            throw HepticError.notSupportedDevice
        }
        
        if engine == nil {
            engine = try CHHapticEngine()
        }
        
        try engine?.start()
    }
    
    func stop() {
        engine?.stop()
        engine = nil
    }
    
    func perform() throws {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            throw HepticError.notSupportedDevice
        }

        var events = [CHHapticEvent]()

        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)

        let pattern = try CHHapticPattern(events: events, parameters: [])
        let player = try engine?.makePlayer(with: pattern)
        try player?.start(atTime: 0)
    }
}

enum HepticError: Error {
    case notSupportedDevice
}

import SwiftUI

extension UIDevice {
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    static var simulatorDeviceIdentifier: String? {
        guard isSimulator else { return nil }
        
        return ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"]
    }
    
    static var currentDeviceIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        if isSimulator {
            let simulatorName = simulatorDeviceIdentifier ?? "Unknown Simulator"
            print("Running in Simulator: \(simulatorName) with device identifier: \(identifier)")
        }
        
        return identifier
    }
    
    static var deviceName: String {
        if isSimulator {
            return simulatorDeviceIdentifier ?? "iOS Simulator"
        } else {
            return UIDevice.current.name
        }
    }
    
    static var deviceInfo: String {
        let identifier = currentDeviceIdentifier
        let name = deviceName
        let systemVersion = UIDevice.current.systemVersion
        let model = UIDevice.current.model
        
        return """
        Device Info:
        - Name: \(name)
        - Model: \(model)
        - System: iOS \(systemVersion)
        - Identifier: \(identifier)
        - Is Simulator: \(isSimulator)
        """
    }
    
    static var dynamicIslandWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        
        // Get device model identifier for more accurate detection
        let identifier = currentDeviceIdentifier
        
        // Dynamic Island devices (iPhone 14 Pro series, iPhone 15 Pro series, and iPhone 16 series)
        if identifier.contains("iPhone15,2") || identifier.contains("iPhone15,3") || // iPhone 14 Pro, 14 Pro Max
           identifier.contains("iPhone16,1") || identifier.contains("iPhone16,2") || // iPhone 15 Pro, 15 Pro Max
           identifier.contains("iPhone17,1") || identifier.contains("iPhone17,2") {  // iPhone 16 Pro, 16 Pro Max
            return 126 // Original Dynamic Island width
        }
        // iPhone 14, 14 Plus, 15, 15 Plus (no Dynamic Island, but wider status bar area)
        else if identifier.contains("iPhone15,4") || identifier.contains("iPhone15,5") || // iPhone 14, 14 Plus
                identifier.contains("iPhone16,3") || identifier.contains("iPhone16,4") {  // iPhone 15, 15 Plus
            return 170 // Wider for devices without Dynamic Island
        }
        // iPhone 13 series (no Dynamic Island)
        else if identifier.contains("iPhone14,5") || identifier.contains("iPhone14,2") || identifier.contains("iPhone14,3") {
            return 170 // Wider for devices without Dynamic Island
        }
        // iPhone 12 series (no Dynamic Island)
        else if identifier.contains("iPhone13,2") || identifier.contains("iPhone13,3") || identifier.contains("iPhone13,4") {
            return 170 // Wider for devices without Dynamic Island
        }
        // iPhone 11 series (no Dynamic Island)
        else if identifier.contains("iPhone12,1") || identifier.contains("iPhone12,3") || identifier.contains("iPhone12,5") {
            return 170 // Wider for devices without Dynamic Island
        }
        // iPhone X series (no Dynamic Island)
        else if identifier.contains("iPhone10,3") || identifier.contains("iPhone10,6") || identifier.contains("iPhone11,8") || identifier.contains("iPhone11,6") || identifier.contains("iPhone11,2") {
            return 170 // Wider for devices without Dynamic Island
        }
        // iPhone mini series (smaller screens, wider status bar area)
        else if identifier.contains("iPhone14,4") || identifier.contains("iPhone14,6") || // iPhone 13 mini, 12 mini
               identifier.contains("iPhone15,4") || identifier.contains("iPhone15,5") {  // iPhone 14 mini, 15 mini
            return 190 // Even wider for mini devices
        }
        // For other devices, use screen width based calculation
        else {
            // Fallback to a percentage of screen width
            return screenWidth * 0.45 // Approximately 45% of screen width for unknown devices
        }
    }
    
}

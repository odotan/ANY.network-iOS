import SwiftUI

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var red: Double = 0.0
        var green: Double = 0.0
        var blue: Double = 0.0
        var opacity: Double = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            red = Double((rgb & 0xFF0000) >> 16) / 255.0
            green = Double((rgb & 0x00FF00) >> 8) / 255.0
            blue = Double(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            red = Double((rgb & 0xFF000000) >> 24) / 255.0
            green = Double((rgb & 0x00FF0000) >> 16) / 255.0
            blue = Double((rgb & 0x0000FF00) >> 8) / 255.0
            opacity = Double(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    /// Returns the RGB components of the color if possible (sRGB only)
    var rgbComponents: (red: Double, green: Double, blue: Double, opacity: Double)? {
        #if canImport(UIKit)
        let nativeColor = UIColor(self)
        #elseif canImport(AppKit)
        let nativeColor = NSColor(self)
        #endif
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard nativeColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        return (Double(red), Double(green), Double(blue), Double(alpha))
    }
    /// Returns the HSB (hue, saturation, brightness) components of the color if possible (sRGB only)
    var hsbComponents: (hue: Double, saturation: Double, brightness: Double, opacity: Double)? {
        #if canImport(UIKit)
        let nativeColor = UIColor(self)
        #elseif canImport(AppKit)
        let nativeColor = NSColor(self)
        #endif
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        guard nativeColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return nil
        }
        return (Double(hue), Double(saturation), Double(brightness), Double(alpha))
    }
}

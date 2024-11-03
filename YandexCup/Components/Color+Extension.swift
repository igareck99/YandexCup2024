import SwiftUI

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        let length = hexSanitized.count

        guard length == 6 || length == 8
        else { fatalError("fatalError: HEX to Color convertion, wrong length") }

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb)
        else { fatalError("fatalError: HEX to Color convertion, scanHexInt64failure") }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            fatalError("fatalError: HEX to Color convertion, can't detect length")
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    static let limebuzz = Color(hex: "A8DB10")
    static let bluesaphire = Color(hex: "1976D2")
    static let flameburst = Color(hex: "FF3D00")
    static let urbangrey = Color(hex: "8B8B8B")
}

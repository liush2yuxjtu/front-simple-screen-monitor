import SwiftUI

enum TerminalNoirTheme {
    static let background = Color(hex: 0x04080F)
    static let surface = Color(hex: 0x0A1520)
    static let surfaceElevated = Color(hex: 0x0E1C2B)
    static let phoneFrame = Color(hex: 0x050B12)
    static let phoneMetal = Color(hex: 0x101923)
    static let cyan = Color(hex: 0x00E5FF)
    static let lime = Color(hex: 0x76FF03)
    static let red = Color(hex: 0xFF1744)
    static let amber = Color(hex: 0xFFC107)
    static let text = Color(hex: 0xE0F7FA)
    static let muted = Color(hex: 0x4A6A7A)
    static let border = Color(hex: 0x1A3A4A)
    static let card = Color(hex: 0x0A1520, opacity: 0.84)
    static let glass = Color(hex: 0x0A1520, opacity: 0.72)
}

extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

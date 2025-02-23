//
//  Color+EXT.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/22/25.
//

import SwiftUI

extension Color {
    /// Initializes a Color from a hex string (e.g., "#RRGGBB" or "RRGGBB").
    init(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var hexInt: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&hexInt)
        
        let red, green, blue, alpha: Double
        switch hexString.count {
        case 6: // RGB (no alpha)
            red = Double((hexInt >> 16) & 0xFF) / 255.0
            green = Double((hexInt >> 8) & 0xFF) / 255.0
            blue = Double(hexInt & 0xFF) / 255.0
            alpha = 1.0
        case 8: // ARGB
            alpha = Double((hexInt >> 24) & 0xFF) / 255.0
            red = Double((hexInt >> 16) & 0xFF) / 255.0
            green = Double((hexInt >> 8) & 0xFF) / 255.0
            blue = Double(hexInt & 0xFF) / 255.0
        default:
            red = 0
            green = 0
            blue = 0
            alpha = 1.0
        }
        
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    /// Converts a `Color` instance to a hex string representation.
    func toHex(includeAlpha: Bool = false) -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let red = Int((components[0] * 255).rounded())
        let green = Int((components[1] * 255).rounded())
        let blue = Int((components[2] * 255).rounded())
        let alpha = components.count >= 4 ? Int((components[3] * 255).rounded()) : 255
        
        if includeAlpha {
            return String(format: "#%02X%02X%02X%02X", alpha, red, green, blue)
        } else {
            return String(format: "#%02X%02X%02X", red, green, blue)
        }
    }
}

//
//  ColorScheme+EXT.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/15/25.
//

import SwiftUI

extension ColorScheme {
    var backgroundPrimary: Color {
        self == .dark ? Color(uiColor: .secondarySystemBackground) : Color(uiColor: .systemBackground)
    }
    
    var backgroundSecondary: Color {
        self == .dark ? Color(uiColor: .systemBackground) : Color(uiColor: .secondarySystemBackground)
    }
}

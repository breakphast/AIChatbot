//
//  CategoryRowTestOption.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/18/25.
//

import SwiftUI

enum CategoryRowTestOption: String, Codable, CaseIterable {
    case original, top, hidden
    
    static var `default`: Self {
        .original
    }
}

enum PaywallTestOption: String, Codable, CaseIterable {
    case custom, storeKit, revenueCat
    
    static var `default`: Self {
        .storeKit
    }
}

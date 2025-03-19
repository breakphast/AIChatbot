//
//  EntitlementOption.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/19/25.
//

import SwiftUI

enum EntitlementOption: Codable, CaseIterable {
    case yearly
    
    var productID: String {
        switch self {
        case .yearly:
            return "devsmond.AIChatBot.yearly"
        }
    }
    
    static var allProductIDs: [String] {
        EntitlementOption.allCases.map { $0.productID }
    }
}

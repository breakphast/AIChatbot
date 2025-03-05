//
//  Collection+EXT.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/4/25.
//

import SwiftUI

extension Collection {
    func first(upTo value: Int) -> [Element]? {
        guard !isEmpty else { return nil }
        
        let maxItems = Swift.min(count, value)
        
        return Array(prefix(maxItems))
    }
    
    func last(upTo value: Int) -> [Element]? {
        guard !isEmpty else { return nil }
        
        let maxItems = Swift.min(count, value)
        
        return Array(suffix(maxItems))
    }
}

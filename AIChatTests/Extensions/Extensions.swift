//
//  Extensions.swift
//  AIChatTests
//
//  Created by Desmond Fitch on 3/21/25.
//

import Foundation
@testable import AIChatbot

extension String {
    static var random: String {
        let adjectives = ["Swift", "Brave", "Clever", "Quiet", "Witty"]
        let nouns = ["Fox", "Tiger", "Hawk", "Panda", "Otter"]
        return "\(adjectives.randomElement()!)\(nouns.randomElement()!)\(Int.random(in: 1...99))"
    }
    
    static var email: String {
        return "\(String.random.lowercased())@example.com"
    }

    static var hexColor: String {
        String(format: "#%06X", Int.random(in: 0...0xFFFFFF))
    }
}

extension Bool {
    static var random: Bool {
        [true, false].randomElement()!
    }
}

extension Date {
    static var random: Date {
        let daysAgo = Int.random(in: 0...1000)
        return Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
    }
    
    var truncatedToSeconds: Date {
        let time = timeIntervalSince1970
        let truncated = floor(time)
        return Date(timeIntervalSince1970: truncated)
    }
}

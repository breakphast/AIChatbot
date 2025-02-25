//
//  TextValidationHelper.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/25/25.
//

import Foundation

struct TextValidationHelper {
    enum TextValidationError: LocalizedError {
        case notEnoughCharacters(min: Int)
        case hasBadWords
        
        var errorDescription: String? {
            switch self {
            case .notEnoughCharacters(min: let min):
                return "Please add at least \(min) characters."
            case .hasBadWords:
                return "Bad word detected. Please rephrase your message."
            }
        }
    }
    
    static func checkIfTextIsValid(text: String) throws {
        let minimumCharactersCount: Int = 3
        
        guard text.count >= minimumCharactersCount else {
            throw TextValidationError.notEnoughCharacters(min: minimumCharactersCount)
        }
        
        let badWords: [String] = [
            "shit", "bitch", "ass"
        ]
        if badWords.contains(text.lowercased()) {
            throw TextValidationError.hasBadWords
        }
    }
}

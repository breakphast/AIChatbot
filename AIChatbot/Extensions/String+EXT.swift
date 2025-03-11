//
//  String+EXT.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/10/25.
//

import Foundation

extension String {
    static func convertToString(_ value: Any) -> String? {
        switch value {
        case let value as String:
            return value
        case let value as Int:
            return "\(value)"
        case let value as Double:
            return "\(value)"
        case let value as Bool:
            return value.description
        case let value as Float:
            return "\(value)"
        case let value as Date:
            return value.formatted(date: .abbreviated, time: .shortened)
        case let array as [Any]:
            return array.compactMap { String.convertToString($0) }.sorted().joined(separator: ", ")
        case let value as CustomStringConvertible:
            return value.description
        default:
            return nil
        }
    }
    
    func clipped(maxCharacters: Int) -> String {
        String(prefix(maxCharacters))
    }
    
    func replaceSpacesWithUnderscores() -> String {
        replacingOccurrences(of: " ", with: "_")
    }
}

extension String {
   var stableHashValue: Int {
        let unicodeScalars = self.unicodeScalars.map { $0.value }
        return unicodeScalars.reduce(5381) { ($0 << 5) &+ $0 &+ Int($1) }
    }
}

//
//  FileManager+EXT.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/4/25.
//

import SwiftUI

extension FileManager {

    static func saveDocument<T: Codable>(key: String, value: T?) throws {
        let data = try JSONEncoder().encode(value)
        let url = getDocumentURL(for: key)
        try data.write(to: url)
    }

    static func getDocument<T: Codable>(key: String) throws -> T? {
        let url = getDocumentURL(for: key)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private static func getDocumentURL(for key: String) -> URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("\(key).txt")
    }
}

//
//  MockAIService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/4/25.
//

import SwiftUI

struct MockAIService: AIService {
    func generateImage(input: String) async throws -> UIImage {
        try await Task.sleep(for: .seconds(3))
        return UIImage(systemName: "star.fill")!
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await Task.sleep(for: .seconds(3))
        return AIChatModel(role: .user, content: "This is returned text from the AI")
    }
}

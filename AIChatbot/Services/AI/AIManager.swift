//
//  AIManager.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/4/25.
//

import SwiftUI

@MainActor
@Observable
class AIManager {
    private let service: AIService
    
    init(service: AIService) {
        self.service = service
    }
    
    func generateImage(input: String) async throws -> UIImage {
        try await service.generateImage(input: input)
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await service.generateText(chats: chats)
    }
}

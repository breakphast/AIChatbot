//
//  AIService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/4/25.
//

import SwiftUI

protocol AIService: Sendable {
    func generateImage(input: String) async throws -> UIImage
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel
}

//
//  MockChatService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/8/25.
//

import SwiftUI

struct MockChatService: ChatService {
    let chats: [ChatModel]
    let delay: Double
    let showError: Bool
    
    init(chats: [ChatModel] = ChatModel.mocks, delay: Double = 0, showError: Bool = false) {
        self.chats = chats
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func createNewChat(chat: ChatModel) async throws {
        
    }
    
    func addChatMessage(chatID: String, message: ChatMessageModel) async throws {
        
    }
    
    func getChat(userID: String, avatarID: String) async throws -> ChatModel? {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return chats.first(where: { $0.userID == userID && $0.avatarID == avatarID })
    }
    
    func getAllChats(userID: String) async throws -> [ChatModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return chats
    }
    
    func getLastChatMesssage(chatID: String) async throws -> ChatMessageModel? {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return ChatMessageModel.mocks.randomElement()
    }
    
    func streamChatMessages(chatID: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        AsyncThrowingStream { _ in
            
        }
    }
    
    func deleteChat(chatID: String) async throws {
        
    }
    
    func deleteAllChatsForUser(userID: String) async throws {
        
    }
    
    func reportChat(report: ChatReportModel) async throws {
        
    }
}

//
//  MockChatService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/8/25.
//

import SwiftUI

@MainActor
class MockChatService: ChatService {
    let chats: [ChatModel]
    @Published private var messages: [ChatMessageModel]
    let delay: Double
    let showError: Bool
    
    init(
        chats: [ChatModel] = ChatModel.mocks,
        messages: [ChatMessageModel] = ChatMessageModel.mocks,
        delay: Double = 0,
        showError: Bool = false
    ) {
        self.chats = chats
        self.messages = messages
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
        messages.append(message)
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
        AsyncThrowingStream { continutation in
            continutation.yield(messages)
            
            Task {
                for await value in $messages.values {
                    continutation.yield(value)
                }
            }
        }
    }
    
    func deleteChat(chatID: String) async throws {
        
    }
    
    func deleteAllChatsForUser(userID: String) async throws {
        
    }
    
    func reportChat(report: ChatReportModel) async throws {
        
    }
    
    func markChatMessageAsSeen(chatID: String, messageID: String, userID: String) async throws {
        
    }
}

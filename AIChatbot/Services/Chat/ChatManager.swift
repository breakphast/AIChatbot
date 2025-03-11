//
//  ChatManager.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/6/25.
//

import SwiftUI

@MainActor
@Observable
class ChatManager: ObservableObject {
    private let service: ChatService
    
    init(service: ChatService) {
        self.service = service
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try await service.createNewChat(chat: chat)
    }
    
    func addChatMessage(chatID: String, message: ChatMessageModel) async throws {
        try await service.addChatMessage(chatID: chatID, message: message)
    }
    
    func markChatMessageAsSeen(chatID: String, messageID: String, userID: String) async throws {
        try await service.markChatMessageAsSeen(chatID: chatID, messageID: messageID, userID: userID)
    }
    
    func getChat(userID: String, avatarID: String) async throws -> ChatModel? {
        try await service.getChat(userID: userID, avatarID: avatarID)
    }
    
    func getLastChatMesssage(chatID: String) async throws -> ChatMessageModel? {
        try await service.getLastChatMesssage(chatID: chatID)
    }
    
    func streamChatMessages(chatID: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        service.streamChatMessages(chatID: chatID)
    }
    
    func getAllChats(userID: String) async throws -> [ChatModel] {
        try await service.getAllChats(userID: userID)
    }
    
    func deleteChat(chatID: String) async throws {
        try await service.deleteChat(chatID: chatID)
    }

    func deleteAllChatsForUser(userID: String) async throws {
        try await service.deleteAllChatsForUser(userID: userID)
    }
    
    func reportChat(chatID: String, userID: String) async throws {
        let report = ChatReportModel.new(chatID: chatID, userID: userID)
        try await service.reportChat(report: report)
    }
}

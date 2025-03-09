//
//  ChatService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/8/25.
//

import SwiftUI

protocol ChatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
    func addChatMessage(chatID: String, message: ChatMessageModel) async throws
    func markChatMessageAsSeen(chatID: String, messageID: String, userID: String) async throws
    func getChat(userID: String, avatarID: String) async throws -> ChatModel?
    func getAllChats(userID: String) async throws -> [ChatModel]
    @MainActor func streamChatMessages(chatID: String) -> AsyncThrowingStream<[ChatMessageModel], Error>
    func getLastChatMesssage(chatID: String) async throws -> ChatMessageModel?
    func deleteChat(chatID: String) async throws
    func deleteAllChatsForUser(userID: String) async throws
    func reportChat(report: ChatReportModel) async throws
}

//
//  ChatInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol ChatInteractor: GlobalInteractor {
    var currentUser: UserModel? { get }
    var isPremium: Bool { get }
    
    func getAvatar(id: String) async throws -> AvatarModel
    func getRecentAvatars() throws -> [AvatarModel]
    func addRecentAvatar(avatar: AvatarModel) async throws
    func getAuthID() throws -> String
    func getChat(userID: String, avatarID: String) async throws -> ChatModel?
    func streamChatMessages(chatID: String) -> AsyncThrowingStream<[ChatMessageModel], Error>
    func markChatMessageAsSeen(chatID: String, messageID: String, userID: String) async throws
    func addChatMessage(chatID: String, message: ChatMessageModel) async throws
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel
    func createNewChat(chat: ChatModel) async throws
    func reportChat(chatID: String, userID: String) async throws
    func deleteChat(chatID: String) async throws
}

extension CoreInteractor: ChatInteractor { }

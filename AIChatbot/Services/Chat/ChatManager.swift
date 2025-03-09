//
//  ChatManager.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/6/25.
//

import SwiftUI
import FirebaseFirestore
import SwiftfulFirestore
import IdentifiableByString

protocol ChatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
    func addChatMessage(chatID: String, message: ChatMessageModel) async throws
    func getChat(userID: String, avatarID: String) async throws -> ChatModel?
    func getAllChats(userID: String) async throws -> [ChatModel]
    func streamChatMessages(chatID: String) -> AsyncThrowingStream<[ChatMessageModel], Error>
    func getLastChatMesssage(chatID: String) async throws -> ChatMessageModel?
}

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
}

struct FirebaseChatService: ChatService {
    private var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    
    private func messagesCollection(for chatID: String) -> CollectionReference {
        collection.document(chatID).collection("messages")
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try await collection.setDocument(document: chat)
    }
    
    func getChat(userID: String, avatarID: String) async throws -> ChatModel? {
        try await collection.getDocument(id: ChatModel.chatID(userID: userID, avatarID: avatarID))
    }
    
    func getAllChats(userID: String) async throws -> [ChatModel] {
        try await collection
            .whereField(ChatModel.CodingKeys.userID.rawValue, isEqualTo: userID)
            .getAllDocuments()
    }
    
    func addChatMessage(chatID: String, message: ChatMessageModel) async throws {
        try await messagesCollection(for: chatID).setDocument(document: message)
        
        try await collection.updateDocument(id: chatID, dict: [ChatModel.CodingKeys.dateModified.rawValue: Date.now])
    }
    
    func getLastChatMesssage(chatID: String) async throws -> ChatMessageModel? {
        let messages: [ChatMessageModel] = try await messagesCollection(for: chatID)
            .order(by: ChatMessageModel.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: 1)
            .getAllDocuments()
        
        return messages.first
    }
    
    func streamChatMessages(chatID: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        messagesCollection(for: chatID).streamAllDocuments()
    }
}

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
    
    func addchatMessage(chatID: String, message: ChatMessageModel) async throws {
        try await service.addChatMessage(chatID: chatID, message: message)
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
}

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
}

struct MockChatService: ChatService {
    func createNewChat(chat: ChatModel) async throws {
        
    }
    
    func addChatMessage(chatID: String, message: ChatMessageModel) async throws {
        
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
    
    func addChatMessage(chatID: String, message: ChatMessageModel) async throws {
        try await messagesCollection(for: chatID).setDocument(document: message)
        
        try await collection.updateDocument(id: chatID, dict: [ChatModel.CodingKeys.dateModified.rawValue: Date.now])
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
}

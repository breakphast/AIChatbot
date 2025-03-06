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
}

struct MockChatService: ChatService {
    func createNewChat(chat: ChatModel) async throws {
        
    }
}

struct FirebaseChatService: ChatService {
    var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try await collection.setDocument(document: chat)
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
}

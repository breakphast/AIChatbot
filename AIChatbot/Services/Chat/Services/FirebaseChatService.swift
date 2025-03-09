//
//  FirebaseChatService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/8/25.
//

import SwiftUI
import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseChatService: ChatService {
    private var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    
    private func messagesCollection(for chatID: String) -> CollectionReference {
        collection.document(chatID).collection("messages")
    }
    
    private var chatReportsCollection: CollectionReference {
        Firestore.firestore().collection("chat_reports")
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
    
    func markChatMessageAsSeen(chatID: String, messageID: String, userID: String) async throws {
        try await messagesCollection(for: chatID).document(messageID).updateData([
            ChatMessageModel.CodingKeys.seenByIDs.rawValue: FieldValue.arrayUnion([userID])
        ])
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
    
    func deleteChat(chatID: String) async throws {
        async let deleteChat: () = collection.deleteDocument(id: chatID)
        async let deleteMessages: () = messagesCollection(for: chatID).deleteAllDocuments()
        
        let (_, _) = await (try deleteChat, try deleteMessages)
    }
    
    func deleteAllChatsForUser(userID: String) async throws {
        let allChats = try await getAllChats(userID: userID)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for chat in allChats {
                group.addTask {
                    try await deleteChat(chatID: chat.id)
                }
            }
            
            try await group.waitForAll()
        }
    }
    
    func reportChat(report: ChatReportModel) async throws {
        try await chatReportsCollection.setDocument(document: report)
    }
}

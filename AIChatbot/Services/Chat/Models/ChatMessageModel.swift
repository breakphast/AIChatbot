//
//  ChatMessageModel.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/22/25.
//

import Foundation

struct ChatMessageModel: Identifiable {
    let id: String
    let chatID: String
    let authorID: String?
    let content: AIChatModel?
    let seenByIDs: [String]?
    let dateCreated: Date?
    
    init(
        id: String,
        chatID: String,
        authorID: String? = nil,
        content: AIChatModel? = nil,
        seenByIDs: [String]? = nil,
        dateCreated: Date? = nil
    ) {
        self.id = id
        self.chatID = chatID
        self.authorID = authorID
        self.content = content
        self.seenByIDs = seenByIDs
        self.dateCreated = dateCreated
    }
    
    static func newUserMessage(chatID: String, userID: String, message: AIChatModel) -> Self {
        ChatMessageModel(
            id: UUID().uuidString,
            chatID: chatID,
            authorID: userID,
            content: message,
            seenByIDs: [userID],
            dateCreated: .now
        )
    }
    
    static func newAIMessage(chatID: String, avatarID: String, message: AIChatModel) -> Self {
        ChatMessageModel(
            id: UUID().uuidString,
            chatID: chatID,
            authorID: avatarID,
            content: message,
            seenByIDs: [],
            dateCreated: .now
        )
    }
    
    static var mock: ChatMessageModel {
        mocks[0]
    }
    
    func hasBeenSeenBy(_ userID: String) -> Bool {
        guard let seenByIDs else { return false }
        
        return seenByIDs.contains(userID)
    }
        
    static var mocks: [ChatMessageModel] {
        let now = Date()
        return [
            ChatMessageModel(
                id: "msg1",
                chatID: "1",
                authorID: "user1",
                content: AIChatModel(role: .user, content: "Hello how are you?"),
                seenByIDs: ["user2", "user3"],
                dateCreated: now.adding(minutes: -30)
            ),
            ChatMessageModel(
                id: "msg2",
                chatID: "2",
                authorID: "user2",
                content: AIChatModel(role: .assistant, content: "I'm doing well, thanks for asking!"),
                seenByIDs: ["user1"],
                dateCreated: now.adding(hours: -2)
            ),
            ChatMessageModel(
                id: "msg3",
                chatID: "3",
                authorID: "user3",
                content: AIChatModel(role: .user, content: "Anyone up for a game tonight?"),
                seenByIDs: ["user1", "user2", "user4"],
                dateCreated: now.adding(hours: -4, days: -1)
            ),
            ChatMessageModel(
                id: "msg4",
                chatID: "1",
                authorID: "user1",
                content: AIChatModel(role: .assistant, content: "Sure, count me in!"),
                seenByIDs: nil,
                dateCreated: now.adding(weeks: -1)
            )
        ]
    }
}

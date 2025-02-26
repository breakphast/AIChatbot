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
    let content: String?
    let seenByIDs: [String]?
    let dateCreated: Date?
    
    init(
        id: String,
        chatID: String,
        authorID: String? = nil,
        content: String? = nil,
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
                content: "Hello, how are you?",
                seenByIDs: ["user2", "user3"],
                dateCreated: now.adding(minutes: -30)
            ),
            ChatMessageModel(
                id: "msg2",
                chatID: "2",
                authorID: "user2",
                content: "I'm doing well, thanks for asking!",
                seenByIDs: ["user1"],
                dateCreated: now.adding(hours: -2)
            ),
            ChatMessageModel(
                id: "msg3",
                chatID: "3",
                authorID: "user3",
                content: "Anyone up for a game tonight?",
                seenByIDs: ["user1", "user2", "user4"],
                dateCreated: now.adding(hours: -4, days: -1)
            ),
            ChatMessageModel(
                id: "msg4",
                chatID: "1",
                authorID: "user1",
                content: "Sure, count me in!",
                seenByIDs: nil,
                dateCreated: now.adding(weeks: -1)
            )
        ]
    }
}

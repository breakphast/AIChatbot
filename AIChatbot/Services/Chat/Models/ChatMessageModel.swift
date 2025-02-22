//
//  ChatMessageModel.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/22/25.
//

import Foundation

struct ChatMessageModel {
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
                id: "msg_1",
                chatID: "mock_chat_1",
                authorID: "user_1",
                content: "Hey, how's it going?",
                seenByIDs: ["user_2", "user_3"],
                dateCreated: now.adding(minutes: -30)
            ),
            ChatMessageModel(
                id: "msg_2",
                chatID: "mock_chat_2",
                authorID: "user_2",
                content: "Not bad, just working on something cool.",
                seenByIDs: ["user_1"],
                dateCreated: now.adding(hours: -2)
            ),
            ChatMessageModel(
                id: "msg_3",
                chatID: "mock_chat_3",
                authorID: "user_3",
                content: "Anyone up for a late-night chat?",
                seenByIDs: ["user_1", "user_2", "user_4"],
                dateCreated: now.adding(hours: -4, days: -1)
            ),
            ChatMessageModel(
                id: "msg_4",
                chatID: "mock_chat_4",
                authorID: "user_4",
                content: "Just finished a big project, feeling great!",
                seenByIDs: ["user_1", "user_2"],
                dateCreated: now.adding(weeks: -1)
            )
        ]
    }
}

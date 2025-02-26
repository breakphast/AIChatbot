//
//  ChatModel.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/22/25.
//

import Foundation

struct ChatModel: Identifiable {
    let id: String
    let userID: String
    let avatarID: String
    let dateCreated: Date
    let dateModified: Date
}

extension ChatModel {
    static var mock: ChatModel {
        mocks[0]
    }
        
    static var mocks: [Self] {
        let now = Date()
        return [
            ChatModel(
                id: "mock_chat_1",
                userID: "user1",
                avatarID: "avatar1",
                dateCreated: now,
                dateModified: now
            ),
            ChatModel(
                id: "mock_chat_2",
                userID: "user2",
                avatarID: "avatar2",
                dateCreated: now.adding(days: -3),
                dateModified: now.adding(hours: -12)
            ),
            ChatModel(
                id: "mock_chat_3",
                userID: "user3",
                avatarID: "avatar3",
                dateCreated: now.adding(weeks: -2),
                dateModified: now.adding(days: -5)
            ),
            ChatModel(
                id: "mock_chat_4",
                userID: "user4",
                avatarID: "avatar4",
                dateCreated: now.adding(months: -1),
                dateModified: now.adding(weeks: -1)
            )
        ]
    }
}

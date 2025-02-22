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
    
    static var mocks: [ChatModel] {
        let now = Date()
        return [
            ChatModel(
                id: "mock_chat_1",
                userID: "user_1",
                avatarID: "avatar_1",
                dateCreated: now.adding(days: -1),
                dateModified: now.adding(hours: -5)
            ),
            ChatModel(
                id: "mock_chat_2",
                userID: "user_2",
                avatarID: "avatar_2",
                dateCreated: now.adding(days: -3),
                dateModified: now.adding(hours: -12)
            ),
            ChatModel(
                id: "mock_chat_3",
                userID: "user_3",
                avatarID: "avatar_3",
                dateCreated: now.adding(weeks: -2),
                dateModified: now.adding(days: -5)
            ),
            ChatModel(
                id: "mock_chat_4",
                userID: "user_4",
                avatarID: "avatar_4",
                dateCreated: now.adding(months: -1),
                dateModified: now.adding(weeks: -1)
            )
        ]
    }
}

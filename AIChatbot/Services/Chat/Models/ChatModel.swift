//
//  ChatModel.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/22/25.
//

import Foundation
import IdentifiableByString

struct ChatModel: Identifiable, Codable, Hashable, StringIdentifiable {
    let id: String
    let userID: String
    let avatarID: String
    let dateCreated: Date
    let dateModified: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case avatarID = "avatar_id"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
    }
    
    static func chatID(userID: String, avatarID: String) -> String {
        "\(userID)_\(avatarID)"
    }
    
    static func new(userID: String, avatarID: String) -> Self {
        ChatModel(
            id: "\(userID)_\(avatarID)",
            userID: userID,
            avatarID: avatarID,
            dateCreated: .now,
            dateModified: .now
        )
    }
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
                userID: UserAuthInfo.mock().uid,
                avatarID: AvatarModel.mock.avatarID,
                dateCreated: now,
                dateModified: now
            ),
            ChatModel(
                id: "mock_chat_2",
                userID: UserAuthInfo.mock().uid,
                avatarID: AvatarModel.mock.avatarID,
                dateCreated: now.adding(days: -3),
                dateModified: now.adding(hours: -12)
            ),
            ChatModel(
                id: "mock_chat_3",
                userID: UserAuthInfo.mock().uid,
                avatarID: AvatarModel.mock.avatarID,
                dateCreated: now.adding(weeks: -2),
                dateModified: now.adding(days: -5)
            ),
            ChatModel(
                id: "mock_chat_4",
                userID: UserAuthInfo.mock().uid,
                avatarID: AvatarModel.mocks.randomElement()!.avatarID,
                dateCreated: now.adding(months: -1),
                dateModified: now.adding(weeks: -1)
            )
        ]
    }
}

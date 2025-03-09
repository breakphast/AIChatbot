//
//  ChatReportModel.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/8/25.
//

import SwiftUI
import IdentifiableByString

struct ChatReportModel: Codable, StringIdentifiable {
    let id: String
    let chatID: String
    let userID: String
    let isActive: Bool
    let dateCreated: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatID = "chat_id"
        case userID = "user_id"
        case isActive = "is_active"
        case dateCreated = "date_created"
    }
    
    static func new(chatID: String, userID: String) -> Self {
        ChatReportModel(
            id: UUID().uuidString,
            chatID: chatID,
            userID: userID,
            isActive: true,
            dateCreated: .now
        )
    }
}

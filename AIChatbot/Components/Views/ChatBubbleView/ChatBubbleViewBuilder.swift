//
//  ChatBubbleViewBuilder.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/25/25.
//

import SwiftUI

struct ChatBubbleViewBuilder: View {
    
    var message: ChatMessageModel = .mock
    var isCurrentUser: Bool = false
    var imageName: String?
    var onProfileImagePressed: () -> Void = { }
    
    var body: some View {
        ChatBubbleView(
            text: message.content?.message ?? "",
            textColor: isCurrentUser ? .white : .primary,
            backgroundColor: isCurrentUser ? .accent : Color(uiColor: .systemGray6),
            imageName: imageName,
            showImage: !isCurrentUser,
            onProfileImagePressed: onProfileImagePressed
        )
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
        .padding(.leading, isCurrentUser ? 75 : 0)
        .padding(.trailing, isCurrentUser ? 0 : 75)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            ChatBubbleViewBuilder()
            ChatBubbleViewBuilder(isCurrentUser: true)
            ChatBubbleViewBuilder(
                message: ChatMessageModel(
                    id: UUID().uuidString,
                    chatID: UUID().uuidString,
                    authorID: UUID().uuidString,
                    content: AIChatModel(role: .user, content: "This is some longer content that goes onto multiple lines and keeps on going to another line."),
                    seenByIDs: nil,
                    dateCreated: .now
                )
            )
            ChatBubbleViewBuilder(
                message: ChatMessageModel(
                    id: UUID().uuidString,
                    chatID: UUID().uuidString,
                    authorID: UUID().uuidString,
                    content: AIChatModel(role: .user, content: "This is some longer content that goes onto multiple lines and keeps on going to another line."),
                    seenByIDs: nil,
                    dateCreated: .now
                ),
                isCurrentUser: true
            )
        }
        .padding(12)
    }
}

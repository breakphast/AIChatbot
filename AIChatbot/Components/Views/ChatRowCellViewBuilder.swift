//
//  ChatRowCellViewBuilder.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/22/25.
//

import SwiftUI

struct ChatRowCellViewBuilder: View {
    var currentUserID: String? = ""
    var chat: ChatModel = .mock
    var getAvatar: () async -> AvatarModel?
    var getLastChatMessage: () async -> ChatMessageModel?
    
    @State private var avatar: AvatarModel?
    @State private var lastChatMessage: ChatMessageModel?
    
    @State private var didLoadAvatar: Bool = false
    @State private var didLoadChatMessage: Bool = false
    
    private var hasNewChat: Bool {
        guard let lastChatMessage, let currentUserID else { return false }
        
        return lastChatMessage.hasBeenSeenBy(currentUserID)
    }
    
    private var isLoading: Bool {
        !(didLoadAvatar && didLoadChatMessage)
    }
    
    private var subheadline: String? {
        if isLoading {
            return "--- ----- ----"
        }
        
        if avatar == nil && lastChatMessage == nil {
            return "Error."
        }
        
        return lastChatMessage?.content
    }
    
    var body: some View {
        ChatRowCellView(
            imageName: avatar?.profileImageName,
            headline: isLoading ? "--- -----" : avatar?.name,
            subheadline: subheadline,
            hasNewChat: isLoading ? false : hasNewChat
        )
        .redacted(reason: isLoading ? .placeholder : [])
        .task {
            avatar = await getAvatar()
            didLoadAvatar = true
        }
        .task {
            lastChatMessage = await getLastChatMessage()
            didLoadChatMessage = true
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ChatRowCellViewBuilder(chat: .mock) {
            try? await Task.sleep(for: .seconds(5))
            return .mock
        } getLastChatMessage: {
            try? await Task.sleep(for: .seconds(5))
            return .mock
        }
        
        ChatRowCellViewBuilder(chat: .mock) {
            .mock
        } getLastChatMessage: {
            .mock
        }
        
        ChatRowCellViewBuilder(chat: .mock) {
            nil
        } getLastChatMessage: {
            nil
        }
    }
}

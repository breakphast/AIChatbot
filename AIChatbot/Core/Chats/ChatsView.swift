//
//  ChatsView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct ChatsView: View {
    @State private var chats = ChatModel.mocks
    @State private var path: [NavigationPathOption] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(chats) { chat in
                    ChatRowCellViewBuilder(
                        currentUserID: nil,
                        chat: chat) {
                            try? await Task.sleep(for: .seconds(5))
                            return AvatarModel.mocks.randomElement()!
                        } getLastChatMessage: {
                            try? await Task.sleep(for: .seconds(5))
                            return ChatMessageModel.mocks.randomElement()!
                        }
                        .anyButton(.highlight, action: {
                            onChatPressed(chat: chat)
                        })
                        .removeListRowFormatting()
                }
            }
            .navigationDestinationForCoreModule(path: $path)
            .navigationTitle("Chats")
        }
    }
    
    private func onChatPressed(chat: ChatModel) {
        path.append(.chat(avatarID: chat.avatarID))
    }
}

#Preview {
    ChatsView()
}

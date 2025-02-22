//
//  ChatsView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct ChatsView: View {
    @State private var chats = ChatModel.mocks
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(chats) { chat in
                    ChatRowCellViewBuilder(
                        currentUserID: nil,
                        chat: chat) {
                            try? await Task.sleep(for: .seconds(5))
                            return .mock
                        } getLastChatMessage: {
                            try? await Task.sleep(for: .seconds(5))
                            return .mock
                        }
                        .anyButton(.highlight, action: {
                            
                        })
                        .removeListRowFormatting()
                }
            }
            .navigationTitle("Chats")
        }
    }
}

#Preview {
    ChatsView()
}

//
//  ChatRowCellViewBuilder.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/22/25.
//

import SwiftUI

struct ChatRowCellViewBuilder: View {
    @State var viewModel: ChatRowCellViewModel
    
    var chat: ChatModel = .mock
    
    var body: some View {
        ChatRowCellView(
            imageName: viewModel.avatar?.profileImageName,
            headline: viewModel.isLoading ? "--- -----" : viewModel.avatar?.name,
            subheadline: viewModel.subheadline,
            hasNewChat: viewModel.isLoading ? false : viewModel.hasNewChat
        )
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
        .task {
            await viewModel.loadAvatar(chat: chat)
        }
        .task {
            await viewModel.loadLastChatMessage(chat: chat)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(
                interactor: CoreInteractor(container: DevPreview.shared.container)
            ),
            chat: .mock
        )
        
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(
                interactor: AnyChatRowCellInteractor(
                    anyGetAvatar: { _ in
                        try? await Task.sleep(for: .seconds(5))
                        return .mock
                    },
                    anyGetLastChatMessage: { _ in
                        try? await Task.sleep(for: .seconds(5))
                        return .mock
                    }
                )
            ),
            chat: .mock
        )
        
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(
                interactor: AnyChatRowCellInteractor(
                    anyGetAvatar: { _ in
                        return .mock
                    },
                    anyGetLastChatMessage: { _ in
                        return .mock
                    }
                )
            ),
            chat: .mock
        )
        
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(
                interactor: AnyChatRowCellInteractor(
                    anyGetAvatar: { _ in
                        throw URLError(.badServerResponse)
                    },
                    anyGetLastChatMessage: { _ in
                        throw URLError(.badServerResponse)
                    }
                )
            ),
            chat: .mock
        )
    }
}

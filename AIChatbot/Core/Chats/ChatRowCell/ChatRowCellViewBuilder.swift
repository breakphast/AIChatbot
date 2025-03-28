//
//  ChatRowCellViewBuilder.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/22/25.
//

import SwiftUI

struct ChatRowCellDelegate {
    var chat: ChatModel = .mock
}

struct ChatRowCellViewBuilder: View {
    @State var viewModel: ChatRowCellViewModel
    
    let delegate: ChatRowCellDelegate
    
    var body: some View {
        ChatRowCellView(
            imageName: viewModel.avatar?.profileImageName,
            headline: viewModel.isLoading ? "--- -----" : viewModel.avatar?.name,
            subheadline: viewModel.subheadline,
            hasNewChat: viewModel.isLoading ? false : viewModel.hasNewChat
        )
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
        .task {
            await viewModel.loadAvatar(chat: delegate.chat)
        }
        .task {
            await viewModel.loadLastChatMessage(chat: delegate.chat)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    
    return VStack(spacing: 12) {
        builder.chatRowCell()
                
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
            delegate: ChatRowCellDelegate()
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
            delegate: ChatRowCellDelegate()
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
            delegate: ChatRowCellDelegate()
        )
    }
}

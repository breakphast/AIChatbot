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
    @State var presenter: ChatRowCellPresenter
    
    let delegate: ChatRowCellDelegate
    
    var body: some View {
        ChatRowCellView(
            imageName: presenter.avatar?.profileImageName,
            headline: presenter.isLoading ? "--- -----" : presenter.avatar?.name,
            subheadline: presenter.subheadline,
            hasNewChat: presenter.isLoading ? false : presenter.hasNewChat
        )
        .redacted(reason: presenter.isLoading ? .placeholder : [])
        .task {
            await presenter.loadAvatar(chat: delegate.chat)
        }
        .task {
            await presenter.loadLastChatMessage(chat: delegate.chat)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    
    return VStack(spacing: 12) {
        builder.chatRowCell()
                
        ChatRowCellViewBuilder(
            presenter: ChatRowCellPresenter(
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
            presenter: ChatRowCellPresenter(
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
            presenter: ChatRowCellPresenter(
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

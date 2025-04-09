//
//  ChatView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/25/25.
//

import SwiftUI

struct ChatViewDelegate {
    var chat: ChatModel?
    var avatarID: String = AvatarModel.mock.avatarID
}

struct ChatView: View {
    @State var presenter: ChatPresenter
    let delegate: ChatViewDelegate
    
    var body: some View {
        VStack(spacing: 0) {
            scrollViewSection
            textfieldSection
        }
//        .animation(.bouncy, value: presenter.showProfileModal)
        .navigationTitle(presenter.avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if presenter.isGeneratingResponse {
                        ProgressView()
                    }
                    
                    Image(systemName: "ellipsis")
                        .padding()
                        .anyButton {
                            presenter.onChatSettingsPressed()
                        }
                }
            }
        }
        .screenAppearAnalytics(name: "ChatView")
        .task {
            await presenter.loadAvatar(avatarID: delegate.avatarID)
        }
        .task {
            await presenter.loadChat(avatarID: delegate.avatarID)
            await presenter.listenForChatMessages()
        }
        .onFirstAppear {
            presenter.onViewFirstAppear(chat: delegate.chat)
        }
    }
    
    func timestampView(date: Date) -> some View {
        Group {
            Text(date.formatted(date: .abbreviated, time: .omitted))
            +
            Text(" • ")
            +
            Text(date.formatted(date: .omitted, time: .shortened))
        }
        .font(.callout)
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .minimumScaleFactor(0.3)
    }
    
    private var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(presenter.chatMessages) { message in
                    if presenter.messageIsDelayed(message: message) {
                        timestampView(date: message.dateCreatedCalculated)
                    }

                    let isCurrentUser = presenter.messageIsCurrentUser(message: message)
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: presenter.currentUser?.profileColorConverted ?? .accent,
                        imageName: isCurrentUser ? nil : presenter.avatar?.profileImageName,
                        onProfileImagePressed: presenter.onAvatarPressed
                    )
                    .onAppear {
                        presenter.onMessageDidAppear(message: message)
                    }
                    .id(message.id)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .rotationEffect(.degrees(-180))
        }
        .scrollIndicators(.hidden)
        .rotationEffect(.degrees(180))
        .animation(.default, value: presenter.chatMessages.count)
        .scrollPosition(id: $presenter.scrollPosition, anchor: .center)
        .animation(.default, value: presenter.scrollPosition)
    }
    
    private var textfieldSection: some View {
        TextField("Say something...", text: $presenter.textFieldText)
            .keyboardType(.alphabet)
            .autocorrectionDisabled()
            .padding(12)
            .padding(.trailing, 60)
            .accessibilityIdentifier("ChatTextField")
            .overlay(
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .padding(.trailing, 4)
                    .foregroundStyle(.accent)
                    .anyButton(.plain, action: {
                        presenter.onSendMessagePressed(avatarID: delegate.avatarID)
                    })
                , alignment: .trailing
            )
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color(uiColor: .systemBackground))
                    
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
            }
            .buttonPaddingSplit(12)
            .background(Color(uiColor: .secondarySystemBackground))
    }
}

#Preview("Working Chat") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    
    return RouterView { router in
        builder.chatView(router: router)
            .previewEnvironment()
    }
}

#Preview("Working Chat - Not Premium") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    
    return RouterView { router in
        builder.chatView(router: router)
    }
    .previewEnvironment()
}

#Preview("Working Chat - Premium") {
    let container = DevPreview.shared.container
    container.register(PurchaseManager.self, service: PurchaseManager(service: MockPurchaseService(activeEntitlements: [.mock])))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.chatView(router: router)
    }
    .previewEnvironment()
}

#Preview("Slow AI Generation") {
    let container = DevPreview.shared.container
    container.register(AIService.self, service: MockAIService(delay: 15, showError: true))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.chatView(router: router)
    }
    .previewEnvironment()
}

#Preview("Failed AI Generation") {
    let container = DevPreview.shared.container
    container.register(AIService.self, service: MockAIService(delay: 2, showError: true))
    container.register(PurchaseManager.self, service: PurchaseManager(service: MockPurchaseService(activeEntitlements: [.mock])))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.chatView(router: router)
    }
    .previewEnvironment()
}

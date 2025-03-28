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
    @Environment(\.dismiss) var dismiss
    @Environment(CoreBuilder.self) private var builder
    @State var viewModel: ChatViewModel
    let delegate: ChatViewDelegate
    
    var body: some View {
        VStack(spacing: 0) {
            scrollViewSection
            textfieldSection
        }
        .animation(.bouncy, value: viewModel.showProfileModal)
        .navigationTitle(viewModel.avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if viewModel.isGeneratingResponse {
                        ProgressView()
                    }
                    
                    Image(systemName: "ellipsis")
                        .padding()
                        .anyButton {
                            viewModel.onChatSettingsPressed {
                                dismiss()
                            }
                        }
                }
            }
        }
        .screenAppearAnalytics(name: "ChatView")
        .showCustomAlert(type: .confirmationDialog, alert: $viewModel.showChatSettings)
        .showCustomAlert(alert: $viewModel.showAlert)
        .showModal(showModal: $viewModel.showProfileModal) {
            if let avatar = viewModel.avatar {
                profileModal(avatar: avatar)
            }
        }
        .sheet(isPresented: $viewModel.showPaywall, content: {
            builder.paywallView()
        })
        .task {
            await viewModel.loadAvatar(avatarID: delegate.avatarID)
        }
        .task {
            await viewModel.loadChat(avatarID: delegate.avatarID)
            await viewModel.listenForChatMessages()
        }
        .onFirstAppear {
            viewModel.onViewFirstAppear(chat: delegate.chat)
        }
    }
    
    func profileModal(avatar: AvatarModel) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterOption?.rawValue.capitalized,
            headline: avatar.characterDescription) {
                viewModel.onProfileModalXMarkPressed()
            }
            .padding(40)
            .transition(.slide)
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
                ForEach(viewModel.chatMessages) { message in
                    if viewModel.messageIsDelayed(message: message) {
                        timestampView(date: message.dateCreatedCalculated)
                    }

                    let isCurrentUser = viewModel.messageIsCurrentUser(message: message)
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: viewModel.currentUser?.profileColorConverted ?? .accent,
                        imageName: isCurrentUser ? nil : viewModel.avatar?.profileImageName,
                        onProfileImagePressed: viewModel.onAvatarPressed
                    )
                    .onAppear {
                        viewModel.onMessageDidAppear(message: message)
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
        .animation(.default, value: viewModel.chatMessages.count)
        .scrollPosition(id: $viewModel.scrollPosition, anchor: .center)
        .animation(.default, value: viewModel.scrollPosition)
    }
    
    private var textfieldSection: some View {
        TextField("Say something...", text: $viewModel.textFieldText)
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
                        viewModel.onSendMessagePressed(avatarID: delegate.avatarID)
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
    
    return NavigationStack {
        builder.chatView()
            .previewEnvironment()
    }
}

#Preview("Working Chat - Not Premium") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    
    return NavigationStack {
        builder.chatView()
            .previewEnvironment()
    }
}

#Preview("Working Chat - Premium") {
    let container = DevPreview.shared.container
    container.register(PurchaseManager.self, service: PurchaseManager(service: MockPurchaseService(activeEntitlements: [.mock])))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return NavigationStack {
        builder.chatView()
            .previewEnvironment()
    }
}

#Preview("Slow AI Generation") {
    let container = DevPreview.shared.container
    container.register(AIManager.self, service: AIManager(service: MockAIService(delay: 10)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return NavigationStack {
        builder.chatView()
            .previewEnvironment()
    }
}

#Preview("Failed AI Generation") {
    let container = DevPreview.shared.container
    container.register(AIManager.self, service: AIManager(service: MockAIService(delay: 2, showError: true)))
    container.register(PurchaseManager.self, service: PurchaseManager(service: MockPurchaseService(activeEntitlements: [.mock])))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return NavigationStack {
        builder.chatView()
            .previewEnvironment()
    }
}

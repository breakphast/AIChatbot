//
//  ChatView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/25/25.
//

import SwiftUI

struct ChatView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AIManager.self) private var aiManager
    @Environment(AuthManager.self) private var authManager
    @Environment(ChatManager.self) private var chatManager
    
    @State private var chatMessages: [ChatMessageModel] = ChatMessageModel.mocks
    @State private var avatar: AvatarModel?
    @State private var currentUser: UserModel?
    @State private var chat: ChatModel?
    
    @State private var textFieldText: String = ""
    @State private var scrollPosition: String?
    
    @State private var showAlert: AnyAppAlert?
    @State private var showChatSettings: AnyAppAlert?
    @State private var showProfileModal = false
    @State private var isGeneratingResponse = false
    
    var avatarID: String = AvatarModel.mock.avatarID
    
    var body: some View {
        VStack(spacing: 0) {
            scrollViewSection
            textfieldSection
        }
        .animation(.bouncy, value: showProfileModal)
        .navigationTitle(avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if isGeneratingResponse {
                        ProgressView()
                    }
                    
                    Image(systemName: "ellipsis")
                        .padding()
                        .anyButton {
                            onChatSettingsPressed()
                        }
                }
            }
        }
        .showCustomAlert(type: .confirmationDialog, alert: $showChatSettings)
        .showCustomAlert(alert: $showAlert)
        .showModal(showModal: $showProfileModal) {
            if let avatar {
                profileModal(avatar: avatar)
            }
        }
        .task {
            await loadAvatar()
        }
        .onAppear {
            loadCurrentUser()
        }
    }
    
    private func loadCurrentUser() {
        currentUser = userManager.currentUser
    }
    
    private func loadAvatar() async {
        do {
            let avatar = try await avatarManager.getAvatar(id: avatarID)
            
            self.avatar = avatar
            try? await avatarManager.addRecentAvatar(avatar: avatar)
        } catch {
            print("Error loading avatar: \(error)")
        }
    }
    
    private var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages) { message in
                    let isCurrentUser = message.authorID == authManager.auth?.uid
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: currentUser?.profileColorConverted ?? .accent,
                        imageName: isCurrentUser ? nil : avatar?.profileImageName,
                        onProfileImagePressed: onAvatarPressed
                    )
                    .id(message.id)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .rotationEffect(.degrees(-180))
        }
        .scrollIndicators(.hidden)
        .rotationEffect(.degrees(180))
        .animation(.default, value: chatMessages.count)
        .scrollPosition(id: $scrollPosition, anchor: .center)
        .animation(.default, value: scrollPosition)
    }
    
    private var textfieldSection: some View {
        TextField("Say something...", text: $textFieldText)
            .keyboardType(.alphabet)
            .autocorrectionDisabled()
            .padding(12)
            .padding(.trailing, 60)
            .overlay(
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .padding(.trailing, 4)
                    .foregroundStyle(.accent)
                    .anyButton(.plain, action: {
                        onSendMessagePressed()
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
    
    private func profileModal(avatar: AvatarModel) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterOption?.rawValue.capitalized,
            headline: avatar.characterDescription) {
                showProfileModal = false
            }
            .padding(40)
            .transition(.slide)
    }
    
    private func onSendMessagePressed() {
        let content = textFieldText
        
        Task {
            do {
                // Get userID
                let uid = try authManager.getAuthID()
                // Validate textField text
                try TextValidationHelper.checkIfTextIsValid(text: content)
                
                // If chat is nil then create a new chat
                if chat == nil {
                    chat = try await createNewChat(uid: uid)
                }
                
                // If there is no chat, throw error (should never happen)
                guard let chat else {
                    throw ChatViewError.noChat
                }
                
                // Create user chat
                let newChatMessage = AIChatModel(role: .user, content: content)
                let message = ChatMessageModel.newUserMessage(chatID: chat.id, userID: uid, message: newChatMessage)
                
                // Upload user chat
                try await chatManager.addchatMessage(chatID: chat.id, message: message)
                chatMessages.append(message)
                
                // Clear text field & scroll to bottom
                scrollPosition = message.id
                textFieldText = ""
                
                // Generate AI response
                isGeneratingResponse = true
                let aiChats = chatMessages.compactMap({ $0.content })
                let response = try await aiManager.generateText(chats: aiChats)

                // Create AI chat
                let newAIMessage = ChatMessageModel.newAIMessage(chatID: chat.id, avatarID: avatarID, message: response)
                
                // Upload AI chat
                try await chatManager.addchatMessage(chatID: chat.id, message: newAIMessage)
                chatMessages.append(newAIMessage)
            } catch let error {
                showAlert = AnyAppAlert(error: error)
            }
            
            isGeneratingResponse = false
        }
    }
    
    enum ChatViewError: LocalizedError {
        case noChat
    }
    
    private func createNewChat(uid: String) async throws -> ChatModel {
        let newChat = ChatModel.new(userID: uid, avatarID: avatarID)
        try await chatManager.createNewChat(chat: newChat)
        return newChat
    }
    
    private func onChatSettingsPressed() {
        showChatSettings = AnyAppAlert(
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group {
                        Button("Report User / Chat", role: .destructive) { }
                        Button("Delete Chat", role: .destructive) { }
                    }
                )
            }
        )
    }
    
    private func onAvatarPressed() {
        showProfileModal = true
    }
}

#Preview("Working Chat") {
    NavigationStack {
        ChatView()
            .previewEnvironment()
    }
}

#Preview("Slow AI Generation") {
    NavigationStack {
        ChatView()
            .environment(AIManager(service: MockAIService(delay: 10)))
            .previewEnvironment()
    }
}

#Preview("Failed AI Generation") {
    NavigationStack {
        ChatView()
            .environment(AIManager(service: MockAIService(delay: 2, showError: true)))
            .previewEnvironment()
    }
}

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
    @Environment(\.dismiss) var dismiss
    
    @State private var chatMessages: [ChatMessageModel] = []
    @State private var avatar: AvatarModel?
    @State private var currentUser: UserModel?
    @State var chat: ChatModel?
    
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
        .task {
            await loadChat()
            await listenForChatMessages()
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
    
    private func loadChat() async {
        do {
            let uid = try authManager.getAuthID()
            chat = try await chatManager.getChat(userID: uid, avatarID: avatarID)
        } catch {
            print("Error loading chat: \(error)")
        }
    }
    
    private func listenForChatMessages() async {
        do {
            let chatID = try getChatID()
            
            for try await value in chatManager.streamChatMessages(chatID: chatID) {
                chatMessages = value.sortedByKeyPath(keyPath: \.dateCreatedCalculated)
                scrollPosition = chatMessages.last?.id
            }
        } catch {
            
        }
    }
    
    private func getChatID() throws -> String {
        guard let chat else {
            throw ChatViewError.noChat
        }
        return chat.id
    }
    
    private var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages) { message in
                    if messageIsDelayed(message: message) {
                        timestampView(date: message.dateCreatedCalculated)
                    }

                    let isCurrentUser = message.authorID == authManager.auth?.uid
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: currentUser?.profileColorConverted ?? .accent,
                        imageName: isCurrentUser ? nil : avatar?.profileImageName,
                        onProfileImagePressed: onAvatarPressed
                    )
                    .onAppear {
                        onMessageDidAppear(message: message)
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
        .animation(.default, value: chatMessages.count)
        .scrollPosition(id: $scrollPosition, anchor: .center)
        .animation(.default, value: scrollPosition)
    }
    
    private func onMessageDidAppear(message: ChatMessageModel) {
        Task {
            do {
                let uid = try authManager.getAuthID()
                let chatID = try getChatID()
                
                guard !message.hasBeenSeenBy(uid) else { return }
                
                try await chatManager.markChatMessageAsSeen(chatID: chatID, messageID: message.id, userID: uid)
            } catch {
                print("Failed to mark message as seen.")
            }
        }
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
    
    private func messageIsDelayed(message: ChatMessageModel) -> Bool {
        let date = message.dateCreatedCalculated
        
        guard let index = chatMessages.firstIndex(where: { $0.id == message.id }),
              chatMessages.indices.contains(index - 1) else {
            return false
        }
        
        let previousMessageDate = chatMessages[index - 1].dateCreatedCalculated
        let timeDiff = date.timeIntervalSince(previousMessageDate)
        
        let threshold: TimeInterval = 60 * 45
        
        return timeDiff > threshold
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
    
    private func timestampView(date: Date) -> some View {
        Group {
            Text(date.formatted(date: .abbreviated, time: .omitted))
            +
            Text(" • ")
            +
            Text(date.formatted(date: .omitted, time: .shortened))
        }
        .font(.callout)
        .foregroundStyle(.secondary)
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
                
                // Clear text field & scroll to bottom
                textFieldText = ""
                
                // Generate AI response
                isGeneratingResponse = true
                var aiChats = chatMessages.compactMap({ $0.content })
                if let avatarDescription = avatar?.characterDescription {
                    let systemMessage = AIChatModel(
                        role: .system,
                        content: "You are a \(avatarDescription) with the intelligence of an AI. We are having a VERY casual conversation. You are my friend."
                    )
                    aiChats.insert(systemMessage, at: 0)
                }
                let response = try await aiManager.generateText(chats: aiChats)

                // Create AI chat
                let newAIMessage = ChatMessageModel.newAIMessage(chatID: chat.id, avatarID: avatarID, message: response)
                
                // Upload AI chat
                try await chatManager.addchatMessage(chatID: chat.id, message: newAIMessage)
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
        
        defer {
            Task {
                await listenForChatMessages()
            }
        }
        
        return newChat
    }
    
    private func onChatSettingsPressed() {
        showChatSettings = AnyAppAlert(
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group {
                        Button("Report User / Chat", role: .destructive) { onReportChatPressed() }
                        Button("Delete Chat", role: .destructive) { onDeleteChatPressed() }
                    }
                )
            }
        )
    }
    
    private func onReportChatPressed() {
        Task {
            do {
                let uid = try authManager.getAuthID()
                let chatID = try getChatID()
                try await chatManager.reportChat(chatID: chatID, userID: uid)
                
                showAlert = AnyAppAlert(
                    title: "🚨 Reported 🚨",
                    subtitle: "We will review the chat shortly. You may leave the app at any time. Thanks for bringing this to our attention."
                )
            } catch {
                showAlert = AnyAppAlert(
                    title: "Something went wrong.",
                    subtitle: "Please check your internet connection and try again."
                )
            }
        }
    }
    
    private func onDeleteChatPressed() {
        Task {
            do {
                let chatID = try getChatID()
                try await chatManager.deleteChat(chatID: chatID)
                
                dismiss()
            } catch {
                showAlert = AnyAppAlert(
                    title: "Something went wrong.",
                    subtitle: "Please check your internet connection and try again."
                )
            }
        }
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

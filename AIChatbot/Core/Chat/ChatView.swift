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
    @Environment(LogManager.self) private var logManager
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
        .screenAppearAnalytics(name: "ChatView")
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
        logManager.trackEvent(event: Event.loadAvatarStart)
        do {
            let avatar = try await avatarManager.getAvatar(id: avatarID)
            logManager.trackEvent(event: Event.loadAvatarSuccess(avatar: avatar))
            
            self.avatar = avatar
            try? await avatarManager.addRecentAvatar(avatar: avatar)
        } catch {
            logManager.trackEvent(event: Event.loadAvatarFail(error: error))
        }
    }
    
    private func loadChat() async {
        logManager.trackEvent(event: Event.loadChatStart)
        do {
            let uid = try authManager.getAuthID()
            chat = try await chatManager.getChat(userID: uid, avatarID: avatarID)
            logManager.trackEvent(event: Event.loadChatSuccess(chat: chat))
        } catch {
            logManager.trackEvent(event: Event.loadChatFail(error: error))
        }
    }
    
    private func listenForChatMessages() async {
        logManager.trackEvent(event: Event.loadMessagesStart)
        do {
            let chatID = try getChatID()
            
            for try await value in chatManager.streamChatMessages(chatID: chatID) {
                chatMessages = value.sortedByKeyPath(keyPath: \.dateCreatedCalculated)
                scrollPosition = chatMessages.last?.id
            }
        } catch {
            logManager.trackEvent(event: Event.loadMessagesFail(error: error))
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
                logManager.trackEvent(event: Event.messageSeenFail(error: error))
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
        .lineLimit(1)
        .minimumScaleFactor(0.3)
    }
    
    private func onSendMessagePressed() {
        let content = textFieldText
        logManager.trackEvent(event: Event.sendMessageStart(chat: chat, avatar: avatar))
        
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
                try await chatManager.addChatMessage(chatID: chat.id, message: message)
                logManager.trackEvent(event: Event.sendMessageSent(chat: chat, avatar: avatar, message: message))
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
                logManager.trackEvent(event: Event.sendMessageResponse(chat: chat, avatar: avatar, message: newAIMessage))
                
                // Upload AI chat
                try await chatManager.addChatMessage(chatID: chat.id, message: newAIMessage)
                logManager.trackEvent(event: Event.sendMessageResponseSent(chat: chat, avatar: avatar, message: message))
            } catch let error {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.sendMessageFail(error: error))
            }
            
            isGeneratingResponse = false
        }
    }
    
    enum ChatViewError: LocalizedError {
        case noChat
    }
    
    private func createNewChat(uid: String) async throws -> ChatModel {
        logManager.trackEvent(event: Event.createChatStart)
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
        logManager.trackEvent(event: Event.chatSettingsPressed)
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
        logManager.trackEvent(event: Event.reportChatStart)
        Task {
            do {
                let uid = try authManager.getAuthID()
                let chatID = try getChatID()
                try await chatManager.reportChat(chatID: chatID, userID: uid)
                logManager.trackEvent(event: Event.reportChatSuccess)
                showAlert = AnyAppAlert(
                    title: "🚨 Reported 🚨",
                    subtitle: "We will review the chat shortly. You may leave the app at any time. Thanks for bringing this to our attention."
                )
            } catch {
                logManager.trackEvent(event: Event.reportChatFail(error: error))
                showAlert = AnyAppAlert(
                    title: "Something went wrong.",
                    subtitle: "Please check your internet connection and try again."
                )
            }
        }
    }
    
    private func onDeleteChatPressed() {
        logManager.trackEvent(event: Event.deleteChatStart)
        Task {
            do {
                let chatID = try getChatID()
                try await chatManager.deleteChat(chatID: chatID)
                logManager.trackEvent(event: Event.deleteChatSuccess)
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.deleteChatFail(error: error))
                showAlert = AnyAppAlert(
                    title: "Something went wrong.",
                    subtitle: "Please check your internet connection and try again."
                )
            }
        }
    }
    
    private func onAvatarPressed() {
        logManager.trackEvent(event: Event.avatarImagePressed(avatar: avatar))
        showProfileModal = true
    }
    
    enum Event: LoggableEvent {
        case loadAvatarStart
        case loadAvatarSuccess(avatar: AvatarModel?)
        case loadAvatarFail(error: Error)
        case loadChatStart
        case loadChatSuccess(chat: ChatModel?)
        case loadChatFail(error: Error)
        case loadMessagesStart
        case loadMessagesFail(error: Error)
        case messageSeenFail(error: Error)
        case sendMessageStart(chat: ChatModel?, avatar: AvatarModel?)
        case sendMessageFail(error: Error)
        case sendMessageSent(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case sendMessageResponse(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case sendMessageResponseSent(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        case createChatStart
        case chatSettingsPressed
        case reportChatStart
        case reportChatSuccess
        case reportChatFail(error: Error)
        case deleteChatStart
        case deleteChatSuccess
        case deleteChatFail(error: Error)
        case avatarImagePressed(avatar: AvatarModel?)
        
        var eventName: String {
            switch self {
            case .loadAvatarStart:              return "ChatView_LoadAvatar_Start"
            case .loadAvatarSuccess:            return "ChatView_LoadAvatar_Success"
            case .loadAvatarFail:               return "ChatView_LoadAvatar_Fail"
            case .loadChatStart:                return "ChatView_LoadChat_Start"
            case .loadChatSuccess:              return "ChatView_LoadChat_Success"
            case .loadChatFail:                 return "ChatView_LoadChat_Fail"
            case .loadMessagesStart:            return "ChatView_LoadMessages_Start"
            case .loadMessagesFail:             return "ChatView_LoadMessages_Fail"
            case .messageSeenFail:              return "ChatView_MessageSeen_Fail"
            case .sendMessageStart:             return "ChatView_SendMessage_Start"
            case .sendMessageFail:              return "ChatView_SendMessage_Fail"
            case .sendMessageSent:              return "ChatView_SendMessage_Sent"
            case .sendMessageResponse:          return "ChatView_SendMessage_Response"
            case .sendMessageResponseSent:      return "ChatView_SendMessage_ResponseSent"
            case .createChatStart:              return "ChatView_CreateChat_Start"
            case .chatSettingsPressed:          return "ChatView_ChatSettings_Pressed"
            case .reportChatStart:              return "ChatView_ReportChat_Start"
            case .reportChatSuccess:            return "ChatView_ReportChat_Success"
            case .reportChatFail:               return "ChatView_ReportChat_Fail"
            case .deleteChatStart:              return "ChatView_DeleteChat_Start"
            case .deleteChatSuccess:            return "ChatView_DeleteChat_Success"
            case .deleteChatFail:               return "ChatView_DeleteChat_Fail"
            case .avatarImagePressed:           return "ChatView_AvatarImage_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarFail(error: let error), .loadChatFail(error: let error), .loadMessagesFail(error: let error), .messageSeenFail(error: let error), .sendMessageFail(error: let error), .reportChatFail(error: let error), .deleteChatFail(error: let error):
                return error.eventParameters
            case .loadAvatarSuccess(avatar: let avatar), .avatarImagePressed(avatar: let avatar):
                return avatar?.eventParameters
            case .loadChatSuccess(chat: let chat):
                return chat?.eventParameters
            case .sendMessageStart(chat: let chat, avatar: let avatar):
                var dict = chat?.eventParameters ?? [:]
                dict.merge(avatar?.eventParameters)
                return dict
            case .sendMessageSent(chat: let chat, avatar: let avatar, message: let message),
                    .sendMessageResponse(chat: let chat, avatar: let avatar, message: let message),
                    .sendMessageResponseSent(chat: let chat, avatar: let avatar, message: let message):
                var dict = chat?.eventParameters ?? [:]
                dict.merge(avatar?.eventParameters)
                dict.merge(message.eventParameters)
                return dict
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadChatFail, .sendMessageFail, .loadMessagesFail:
                return .warning
            case .loadAvatarFail, .messageSeenFail, .reportChatFail, .deleteChatFail:
                return .severe
            default:
                return .analytic
            }
        }
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

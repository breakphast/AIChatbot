//
//  ChatInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/26/25.
//

import SwiftUI

@MainActor
@Observable
class ChatPresenter {
    private let interactor: ChatInteractor
    private let router: ChatRouter
    
    private(set) var chatMessages: [ChatMessageModel] = []
    private(set) var avatar: AvatarModel?
    private(set) var currentUser: UserModel?
    private(set) var isGeneratingResponse = false
    private(set) var chat: ChatModel?
    
    var textFieldText: String = ""
    var scrollPosition: String?
    
    init(interactor: ChatInteractor, router: ChatRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func messageIsCurrentUser(message: ChatMessageModel) -> Bool {
        message.authorID == interactor.currentUser?.userID
    }
    
    func onViewFirstAppear(chat: ChatModel?) {
        currentUser = interactor.currentUser
        self.chat = chat
    }
    
    func loadAvatar(avatarID: String) async {
        interactor.trackEvent(event: Event.loadAvatarStart)
        do {
            let avatar = try await interactor.getAvatar(id: avatarID)
            interactor.trackEvent(event: Event.loadAvatarSuccess(avatar: avatar))
            
            self.avatar = avatar
            try? await interactor.addRecentAvatar(avatar: avatar)
        } catch {
            interactor.trackEvent(event: Event.loadAvatarFail(error: error))
        }
    }
    
    func loadChat(avatarID: String) async {
        interactor.trackEvent(event: Event.loadChatStart)
        do {
            let uid = try interactor.getAuthID()
            chat = try await interactor.getChat(userID: uid, avatarID: avatarID)
            interactor.trackEvent(event: Event.loadChatSuccess(chat: chat))
        } catch {
            interactor.trackEvent(event: Event.loadChatFail(error: error))
        }
    }
    
    func listenForChatMessages() async {
        interactor.trackEvent(event: Event.loadMessagesStart)
        do {
            let chatID = try getChatID()
            
            for try await value in interactor.streamChatMessages(chatID: chatID) {
                chatMessages = value.sortedByKeyPath(keyPath: \.dateCreatedCalculated)
                scrollPosition = chatMessages.last?.id
            }
        } catch {
            interactor.trackEvent(event: Event.loadMessagesFail(error: error))
        }
    }
    
    func getChatID() throws -> String {
        guard let chat else {
            throw ChatViewError.noChat
        }
        return chat.id
    }
    
    func onMessageDidAppear(message: ChatMessageModel) {
        Task {
            do {
                let uid = try interactor.getAuthID()
                let chatID = try getChatID()
                
                guard !message.hasBeenSeenBy(uid) else { return }
                
                try await interactor.markChatMessageAsSeen(chatID: chatID, messageID: message.id, userID: uid)
            } catch {
                interactor.trackEvent(event: Event.messageSeenFail(error: error))
            }
        }
    }
    
    func messageIsDelayed(message: ChatMessageModel) -> Bool {
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
    
    func onSendMessagePressed(avatarID: String) {
        let content = textFieldText
        interactor.trackEvent(event: Event.sendMessageStart(chat: chat, avatar: avatar))
        
        Task {
            do {
                if !interactor.isPremium && chatMessages.count >= 3 {
                    router.showPaywallView()
                    return
                }
                // Get userID
                let uid = try interactor.getAuthID()
                // Validate textField text
                try TextValidationHelper.checkIfTextIsValid(text: content)
                
                // If chat is nil then create a new chat
                if chat == nil {
                    chat = try await createNewChat(uid: uid, avatarID: avatarID)
                }
                
                // If there is no chat, throw error (should never happen)
                guard let chat else {
                    throw ChatViewError.noChat
                }
                
                // Create user chat
                let newChatMessage = AIChatModel(role: .user, content: content)
                let message = ChatMessageModel.newUserMessage(chatID: chat.id, userID: uid, message: newChatMessage)
                
                // Upload user chat
                try await interactor.addChatMessage(chatID: chat.id, message: message)
                interactor.trackEvent(event: Event.sendMessageSent(chat: chat, avatar: avatar, message: message))
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
                let response = try await interactor.generateText(chats: aiChats)

                // Create AI chat
                let newAIMessage = ChatMessageModel.newAIMessage(chatID: chat.id, avatarID: avatarID, message: response)
                interactor.trackEvent(event: Event.sendMessageResponse(chat: chat, avatar: avatar, message: newAIMessage))
                
                // Upload AI chat
                try await interactor.addChatMessage(chatID: chat.id, message: newAIMessage)
                interactor.trackEvent(event: Event.sendMessageResponseSent(chat: chat, avatar: avatar, message: message))
            } catch let error {
                router.showAlert(error: error)
                interactor.trackEvent(event: Event.sendMessageFail(error: error))
            }
            
            isGeneratingResponse = false
        }
    }
    
    enum ChatViewError: LocalizedError {
        case noChat
    }
    
    func createNewChat(uid: String, avatarID: String) async throws -> ChatModel {
        interactor.trackEvent(event: Event.createChatStart)
        let newChat = ChatModel.new(userID: uid, avatarID: avatarID)
        try await interactor.createNewChat(chat: newChat)
        
        defer {
            Task {
                await listenForChatMessages()
            }
        }
        
        return newChat
    }
    
    func onChatSettingsPressed() {
        interactor.trackEvent(event: Event.chatSettingsPressed)
        router.showAlert(
            .confirmationDialog,
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group {
                        Button("Report User / Chat", role: .destructive) {
                            self.onReportChatPressed()
                        }
                        Button("Delete Chat", role: .destructive) {
                            self.onDeleteChatPressed()
                        }
                    }
                )
            }
        )
    }
    
    func onReportChatPressed() {
        interactor.trackEvent(event: Event.reportChatStart)
        Task {
            do {
                let uid = try interactor.getAuthID()
                let chatID = try getChatID()
                try await interactor.reportChat(chatID: chatID, userID: uid)
                interactor.trackEvent(event: Event.reportChatSuccess)
                router.showSimpleAlert(
                    title: "🚨 Reported 🚨",
                    subtitle: "We will review the chat shortly. You may leave the app at any time. Thanks for bringing this to our attention."
                )
            } catch {
                interactor.trackEvent(event: Event.reportChatFail(error: error))
                router.showSimpleAlert(
                        title: "Something went wrong.",
                        subtitle: "Please check your internet connection and try again."
                    )
            }
        }
    }
    
    func onDeleteChatPressed() {
        interactor.trackEvent(event: Event.deleteChatStart)
        
        Task {
            do {
                let chatID = try getChatID()
                try await interactor.deleteChat(chatID: chatID)
                interactor.trackEvent(event: Event.deleteChatSuccess)
                
                router.dismissScreen()
            } catch {
                interactor.trackEvent(event: Event.deleteChatFail(error: error))
                router.showSimpleAlert(
                        title: "Something went wrong.",
                        subtitle: "Please check your internet connection and try again."
                    )
            }
        }
    }
    
    func onAvatarPressed() {
        interactor.trackEvent(event: Event.avatarImagePressed(avatar: avatar))
        
        guard let avatar else { return }
        router.showProfileModal(avatar: avatar) {
            self.router.dismissModal()
        }
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
        case sendMessagePaywall(chat: ChatModel?, avatar: AvatarModel?)
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
            case .sendMessagePaywall:           return "ChatView_SendMessage_Paywall"
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
            case .sendMessageStart(chat: let chat, avatar: let avatar), .sendMessagePaywall(chat: let chat, avatar: let avatar):
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

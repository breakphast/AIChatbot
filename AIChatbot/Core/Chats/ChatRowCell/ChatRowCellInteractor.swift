//
//  ChatRowCellInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/26/25.
//

import SwiftUI

@MainActor
protocol ChatRowCellInteractor {
    var auth: UserAuthInfo? { get }
    func trackEvent(event: LoggableEvent)
    func getAvatar(id: String) async throws -> AvatarModel
    func getLastChatMessage(chatID: String) async throws -> ChatMessageModel?
}

extension CoreInteractor: ChatRowCellInteractor { }

@MainActor
@Observable
class ChatRowCellViewModel {
    private let interactor: ChatRowCellInteractor
    
    private(set) var avatar: AvatarModel?
    private(set) var lastChatMessage: ChatMessageModel?
    
    private(set) var didLoadAvatar: Bool = false
    private(set) var didLoadChatMessage: Bool = false
    
    var hasNewChat: Bool {
        guard let lastChatMessage, let currentUserID = interactor.auth?.uid else { return false }
        
        return !lastChatMessage.hasBeenSeenBy(currentUserID)
    }
    
    var isLoading: Bool {
        !(didLoadAvatar && didLoadChatMessage)
    }
    
    var subheadline: String? {
        if isLoading {
            return "--- ----- ----"
        }
        
        if avatar == nil && lastChatMessage == nil {
            return "Error."
        }
        
        return lastChatMessage?.content?.message
    }
    
    init(interactor: ChatRowCellInteractor) {
        self.interactor = interactor
    }
    
    func loadAvatar(chat: ChatModel) async {
        avatar = try? await interactor.getAvatar(id: chat.avatarID)
        didLoadAvatar = true
    }
    
    func loadLastChatMessage(chat: ChatModel) async {
        lastChatMessage = try? await interactor.getLastChatMessage(chatID: chat.id)
        didLoadChatMessage = true
    }
}

struct AnyChatRowCellInteractor: ChatRowCellInteractor {
    let anyAuth: UserAuthInfo?
    let anyTrackEvent: ((LoggableEvent) -> Void)?
    let anyGetAvatar: (String) async throws -> AvatarModel
    let anyGetLastChatMessage: (String) async throws -> ChatMessageModel?

    init(
        anyAuth: UserAuthInfo? = nil,
        anyTrackEvent: ((LoggableEvent) -> Void)? = nil,
        anyGetAvatar: @escaping (String) async throws -> AvatarModel,
        anyGetLastChatMessage: @escaping (String) async throws -> ChatMessageModel?
    ) {
        self.anyAuth = anyAuth
        self.anyTrackEvent = anyTrackEvent
        self.anyGetAvatar = anyGetAvatar
        self.anyGetLastChatMessage = anyGetLastChatMessage
    }

    init(interactor: ChatRowCellInteractor) {
        self.anyAuth = interactor.auth
        self.anyTrackEvent = interactor.trackEvent
        self.anyGetAvatar = interactor.getAvatar
        self.anyGetLastChatMessage = interactor.getLastChatMessage
    }

    var auth: UserAuthInfo? {
        anyAuth
    }

    func trackEvent(event: LoggableEvent) {
        anyTrackEvent?(event)
    }

    func getAvatar(id: String) async throws -> AvatarModel {
        try await anyGetAvatar(id)
    }

    func getLastChatMessage(chatID: String) async throws -> ChatMessageModel? {
        try await anyGetLastChatMessage(chatID)
    }
}

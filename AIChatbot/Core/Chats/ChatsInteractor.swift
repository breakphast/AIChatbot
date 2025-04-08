//
//  ChatsInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol ChatsInteractor {
    func trackEvent(event: LoggableEvent)
    func getRecentAvatars() throws -> [AvatarModel]
    func getAuthID() throws -> String
    func getAllChats(userID: String) async throws -> [ChatModel]
}

extension CoreInteractor: ChatsInteractor { }

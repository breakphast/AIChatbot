//
//  ProfileInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol ProfileInteractor {
    var currentUser: UserModel? { get }
    func getAvatarsForAuthor(userID: String) async throws -> [AvatarModel]
    func removeAuthorIDFromAvatar(avatarID: String) async throws
    func getAuthID() throws -> String
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProfileInteractor { }

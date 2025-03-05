//
//  AvatarService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/4/25.
//

import SwiftUI

protocol RemoteAvatarService: Sendable {
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
    func getFeaturedAvatars() async throws -> [AvatarModel]
    func getPopularAvatars() async throws -> [AvatarModel]
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel]
    func getAvatarsForAuthor(userID: String) async throws -> [AvatarModel]
    func getAvatar(id: String) async throws -> AvatarModel
    func incrementAvatarClickCount(avatarID: String) async throws
    func removeAuthorIDFromAvatar(avatarID: String) async throws
    func removeAuthorIDFromAllAvatars(userID: String) async throws
}

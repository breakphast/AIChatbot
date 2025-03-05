//
//  AvatarManager.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/4/25.
//

import SwiftUI
import FirebaseFirestore
import SwiftfulFirestore

@MainActor
@Observable
class AvatarManager {
    private let remote: RemoteAvatarService
    private let local: LocalAvatarPersistence
    
    init(service: RemoteAvatarService, local: LocalAvatarPersistence = MockLocalAvatarPersistence()) {
        self.remote = service
        self.local = local
    }
    
    func addRecentAvatar(avatar: AvatarModel) async throws {
        try local.addRecentAvatar(avatar: avatar)
        try await remote.incrementAvatarClickCount(avatarID: avatar.id)
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        try local.getRecentAvatars()
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await remote.getAvatar(id: id)
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await remote.createAvatar(avatar: avatar, image: image)
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await remote.getFeaturedAvatars()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await remote.getPopularAvatars()
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await remote.getAvatarsForCategory(category: category)
    }
    
    func getAvatarsForAuthor(userID: String) async throws -> [AvatarModel] {
        try await remote.getAvatarsForAuthor(userID: userID)
    }
    
    func removeAuthorIDFromAvatar(avatarID: String) async throws {
        try await remote.removeAuthorIDFromAvatar(avatarID: avatarID)
    }
    
    func removeAuthorIDFromAllAvatars(userID: String) async throws {
        try await remote.removeAuthorIDFromAllAvatars(userID: userID)
    }
}

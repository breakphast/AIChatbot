//
//  MockAvatarService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/4/25.
//

import SwiftUI

struct MockAvatarService: AvatarService {
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        return AvatarModel.mocks.shuffled()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        return AvatarModel.mocks.shuffled()
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        return AvatarModel.mocks.shuffled()
    }
    
    func getAvatarsForAuthor(userID: String) async throws -> [AvatarModel] {
        return AvatarModel.mocks.shuffled()
    }
}

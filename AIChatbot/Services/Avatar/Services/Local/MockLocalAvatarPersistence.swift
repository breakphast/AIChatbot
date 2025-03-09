//
//  MockLocalAvatarPersistence.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/5/25.
//

import SwiftUI

struct MockLocalAvatarPersistence: LocalAvatarPersistence {
    let avatars: [AvatarModel]
    
    init(avatars: [AvatarModel] = AvatarModel.mocks) {
        self.avatars = avatars
    }
    
    func addRecentAvatar(avatar: AvatarModel) throws {
        
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        avatars
    }
}

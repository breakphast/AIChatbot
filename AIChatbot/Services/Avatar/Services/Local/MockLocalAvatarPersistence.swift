//
//  MockLocalAvatarPersistence.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/5/25.
//

import SwiftUI

struct MockLocalAvatarPersistence: LocalAvatarPersistence {
    func addRecentAvatar(avatar: AvatarModel) throws {
        
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        AvatarModel.mocks.shuffled()
    }
}

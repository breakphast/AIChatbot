//
//  AvatarEntity.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/5/25.
//

import SwiftData
import SwiftUI

@Model
class AvatarEntity {
    @Attribute(.unique) var avatarID: String
    var name: String?
    var characterOption: CharacterOption?
    var characterAction: CharacterAction?
    var characterLocation: CharacterLocation?
    var profileImageName: String?
    var authorID: String?
    var dateCreated: Date?
    var dateAdded: Date
    
    init(from model: AvatarModel) {
        self.avatarID = model.id
        self.name = model.name
        self.characterOption = model.characterOption
        self.characterAction = model.characterAction
        self.characterLocation = model.characterLocation
        self.profileImageName = model.profileImageName
        self.authorID = model.authorID
        self.dateCreated = model.dateCreated
        self.dateAdded = .now
    }
    
    func toModel() -> AvatarModel {
        AvatarModel.init(
            avatarID: avatarID,
            name: name,
            characterOption: characterOption,
            characterAction: characterAction,
            characterLocation: characterLocation,
            profileImageName: profileImageName,
            authorID: authorID,
            dateCreated: dateCreated
        )
    }
}

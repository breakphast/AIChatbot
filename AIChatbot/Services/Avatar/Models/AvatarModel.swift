//
//  AvatarModel.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/21/25.
//

import Foundation
import SwiftfulFirestore
import IdentifiableByString

struct AvatarModel: Hashable, Codable, StringIdentifiable {
    var id: String {
        avatarID
    }
    let avatarID: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    private(set) var profileImageName: String?
    let authorID: String?
    let dateCreated: Date?

    init(
        avatarID: String,
        name: String? = nil,
        characterOption: CharacterOption? = nil,
        characterAction: CharacterAction? = nil,
        characterLocation: CharacterLocation? = nil,
        profileImageName: String? = nil,
        authorID: String? = nil,
        dateCreated: Date? = nil
    ) {
        self.avatarID = avatarID
        self.name = name
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.authorID = authorID
        self.dateCreated = dateCreated
    }
    
    var characterDescription: String {
        AvatarDescriptionBuilder(avatar: self).characterDescription
    }
    
    mutating func updateProfileImage(imageName: String) {
        profileImageName = imageName
    }
    
    enum CodingKeys: String, CodingKey {
        case avatarID = "avatar_id"
        case name
        case characterOption = "character_option"
        case characterAction = "character_action"
        case characterLocation = "character_location"
        case profileImageName = "profile_image_name"
        case authorID = "author_id"
        case dateCreated = "date_created"
    }
    
    static var mock: AvatarModel {
        mocks[0]
    }
    
    static var mocks: [Self] {
        [
            AvatarModel(avatarID: UUID().uuidString, name: "Alpha", characterOption: .alien, characterAction: .smiling, characterLocation: .park, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now),
            AvatarModel(avatarID: UUID().uuidString, name: "Beta", characterOption: .dog, characterAction: .eating, characterLocation: .forest, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now),
            AvatarModel(avatarID: UUID().uuidString, name: "Gamma", characterOption: .cat, characterAction: .drinking, characterLocation: .city, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now),
            AvatarModel(avatarID: UUID().uuidString, name: "Delta", characterOption: .woman, characterAction: .shopping, characterLocation: .park, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now)
        ]
    }
}

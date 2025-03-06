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
    let clickCount: Int?

    init(
        avatarID: String,
        name: String? = nil,
        characterOption: CharacterOption? = nil,
        characterAction: CharacterAction? = nil,
        characterLocation: CharacterLocation? = nil,
        profileImageName: String? = nil,
        authorID: String? = nil,
        dateCreated: Date? = nil,
        clickCount: Int? = nil
    ) {
        self.avatarID = avatarID
        self.name = name
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.authorID = authorID
        self.dateCreated = dateCreated
        self.clickCount = clickCount
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
        case clickCount = "click_count"
    }
    
    static func newAvatar(name: String, option: CharacterOption, action: CharacterAction, location: CharacterLocation, authorID: String) -> Self {
        AvatarModel(
            avatarID: UUID().uuidString,
            name: name,
            characterOption: option,
            characterAction: action,
            characterLocation: location,
            profileImageName: nil,
            authorID: authorID,
            dateCreated: .now,
            clickCount: 0
        )
    }
    
    static var mock: AvatarModel {
        mocks[0]
    }
    
    static var mocks: [Self] {
        [
            AvatarModel(avatarID: UUID().uuidString, name: "Alpha", characterOption: .alien, characterAction: .smiling, characterLocation: .park, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now, clickCount: 10),
            AvatarModel(avatarID: UUID().uuidString, name: "Beta", characterOption: .dog, characterAction: .eating, characterLocation: .forest, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now, clickCount: 100),
            AvatarModel(avatarID: UUID().uuidString, name: "Gamma", characterOption: .cat, characterAction: .drinking, characterLocation: .city, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now, clickCount: 50),
            AvatarModel(avatarID: UUID().uuidString, name: "Delta", characterOption: .woman, characterAction: .shopping, characterLocation: .park, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now, clickCount: 1)
        ]
    }
}

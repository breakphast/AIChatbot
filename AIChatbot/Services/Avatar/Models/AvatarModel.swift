//
//  AvatarModel.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/21/25.
//

import Foundation

struct AvatarModel {
    let avatarID: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    let profileImageName: String?
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
    
    static var mock: AvatarModel {
        mocks[0]
    }
    
    static var mocks: [AvatarModel] {
        [
            AvatarModel(avatarID: UUID().uuidString, name: "Alpha", characterOption: .alien, characterAction: .crying, characterLocation: .beach, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now),
            AvatarModel(avatarID: UUID().uuidString, name: "Beta", characterOption: .dog, characterAction: .sitting, characterLocation: .forest, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now),
            AvatarModel(avatarID: UUID().uuidString, name: "Gamma", characterOption: .cat, characterAction: .relaxing, characterLocation: .home, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now),
            AvatarModel(avatarID: UUID().uuidString, name: "Delta", characterOption: .woman, characterAction: .shopping, characterLocation: .space, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now),
        ]
    }
}

struct AvatarDescriptionBuilder {
    let characterOption: CharacterOption
    let characterAction: CharacterAction
    let characterLocation: CharacterLocation
    
    var characterDescription: String {
        "A \(characterOption.rawValue) that is \(characterAction.rawValue) at the \(characterLocation.rawValue)"
    }
    
    init(characterOption: CharacterOption, characterAction: CharacterAction, characterLocation: CharacterLocation) {
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
    }
    
    init(avatar: AvatarModel) { // convenience initializer
        self.characterOption = avatar.characterOption ?? .default
        self.characterAction = avatar.characterAction ?? .default
        self.characterLocation = avatar.characterLocation ?? .default
    }
}

enum CharacterOption: String {
    case man, woman, alien, dog, cat
    
    static var `default`: Self {
        .man
    }
}

enum CharacterAction: String {
    case eating, walking, smiling, sitting, drinking, shopping, studying, working, relaxing, fighting, crying
    
    static var `default`: Self {
        .smiling
    }
}

enum CharacterLocation: String {
    case home, park, beach, forest, city, mountain, desert, space
    
    static var `default`: Self {
        .park
    }
}

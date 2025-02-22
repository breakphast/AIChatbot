//
//  AvatarModel.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/21/25.
//

import Foundation

struct AvatarModel: Hashable {
    let avatarID: String
    let name: String?
    let characterOption: CharacterOption
    let characterAction: CharacterAction
    let characterLocation: CharacterLocation
    let profileImageName: String
    let authorID: String?
    let dateCreated: Date?

    init(
        avatarID: String,
        name: String? = nil,
        characterOption: CharacterOption,
        characterAction: CharacterAction,
        characterLocation: CharacterLocation,
        profileImageName: String,
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
        let prefix = characterOption.startsWithVowel ? "An" : "A"
        return "\(prefix) \(AvatarDescriptionBuilder(avatar: self).characterDescription)"
    }
    
    static var mock: AvatarModel {
        mocks[0]
    }
    
    static var mocks: [AvatarModel] {
        [
            AvatarModel(avatarID: "avatar_1", name: "Alpha", characterOption: .alien, characterAction: .crying, characterLocation: .beach, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now),
            AvatarModel(avatarID: UUID().uuidString, name: "Beta", characterOption: .dog, characterAction: .sitting, characterLocation: .forest, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now),
            AvatarModel(avatarID: UUID().uuidString, name: "Gamma", characterOption: .cat, characterAction: .relaxing, characterLocation: .home, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now),
            AvatarModel(avatarID: UUID().uuidString, name: "Delta", characterOption: .woman, characterAction: .shopping, characterLocation: .space, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now)
        ]
    }
}

struct AvatarDescriptionBuilder {
    let characterOption: CharacterOption
    let characterAction: CharacterAction
    let characterLocation: CharacterLocation
    
    var characterDescription: String {
        "\(characterOption.rawValue) that is \(characterAction.rawValue) at the \(characterLocation.rawValue)"
    }
    
    init(characterOption: CharacterOption, characterAction: CharacterAction, characterLocation: CharacterLocation) {
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
    }
    
    init(avatar: AvatarModel) { // convenience initializer
        self.characterOption = avatar.characterOption
        self.characterAction = avatar.characterAction
        self.characterLocation = avatar.characterLocation
    }
}

enum CharacterOption: String, CaseIterable, Hashable {
    case man, woman, alien, dog, cat
    
    static var `default`: Self {
        .man
    }
    
    var startsWithVowel: Bool {
        switch self {
        case .alien:
            true
        default:
            false
        }
    }
    
    var textdescription: String {
        switch self {
        case .man:
            "Men"
        case .woman:
            "Women"
        case .alien:
            "Aliens"
        case .dog:
            "Dogs"
        case .cat:
            "Cats"
        }
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

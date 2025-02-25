//
//  CharacterAttributes.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/25/25.
//

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

enum CharacterAction: String, CaseIterable, Hashable {
    case eating, walking, smiling, sitting, drinking, shopping, studying, working, relaxing, fighting, crying
    
    static var `default`: Self {
        .smiling
    }
}

enum CharacterLocation: String, CaseIterable, Hashable {
    case home, park, beach, forest, city, mountain, desert, space
    
    static var `default`: Self {
        .park
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

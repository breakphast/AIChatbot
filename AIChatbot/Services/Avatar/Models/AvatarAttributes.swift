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
            return true
        default:
            return false
        }
    }
    
    var pluralized: String {
        switch self {
        case .man:
            "men"
        case .woman:
            "women"
        case .alien:
            "aliens"
        case .dog:
            "dogs"
        case .cat:
            "cats"
        }
    }
}

enum CharacterAction: String, CaseIterable, Hashable {
    case smiling, sitting, eating, drinking, walking, shopping, studying, working, relaxing, fighting, crying
    
    static var `default`: Self {
        .smiling
    }
}

enum CharacterLocation: String, CaseIterable, Hashable {
    case park, mall, museum, city, desert, forest, space
    
    static var `default`: Self {
        .park
    }
}

struct AvatarDescriptionBuilder {
    let characterOption: CharacterOption
    let characterAction: CharacterAction
    let characterLocation: CharacterLocation

    init(characterOption: CharacterOption, characterAction: CharacterAction, characterLocation: CharacterLocation) {
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
    }
    
    init(avatar: AvatarModel) {
        self.characterOption = avatar.characterOption ?? .default
        self.characterAction = avatar.characterAction ?? .default
        self.characterLocation = avatar.characterLocation ?? .default
    }
    
    var characterDescription: String {
        let prefix = characterOption.startsWithVowel ? "An" : "A"
        return "\(prefix) \(characterOption.rawValue) that is \(characterAction.rawValue) in the \(characterLocation.rawValue)."
    }
}

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
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "avatar_\(CodingKeys.avatarID.rawValue)": avatarID,
            "avatar_\(CodingKeys.name.rawValue)": name,
            "avatar_\(CodingKeys.characterOption.rawValue)": characterOption?.rawValue,
            "avatar_\(CodingKeys.characterAction.rawValue)": characterAction?.rawValue,
            "avatar_\(CodingKeys.characterLocation.rawValue)": characterLocation?.rawValue,
            "avatar_\(CodingKeys.profileImageName.rawValue)": profileImageName,
            "avatar_\(CodingKeys.authorID.rawValue)": authorID,
            "avatar_\(CodingKeys.dateCreated.rawValue)": dateCreated,
            "avatar_\(CodingKeys.clickCount.rawValue)": clickCount
        ]
        
        return dict.compactMapValues { $0 }
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
            AvatarModel(avatarID: "mock_ava_1", name: "Alpha", characterOption: .alien, characterAction: .smiling, characterLocation: .park, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now, clickCount: 10),
            AvatarModel(avatarID: "mock_ava_1", name: "Beta", characterOption: .dog, characterAction: .eating, characterLocation: .forest, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now, clickCount: 100),
            AvatarModel(avatarID: "mock_ava_1", name: "Gamma", characterOption: .cat, characterAction: .drinking, characterLocation: .city, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now, clickCount: 50),
            AvatarModel(avatarID: "mock_ava_1", name: "Delta", characterOption: .woman, characterAction: .shopping, characterLocation: .park, profileImageName: Constants.randomImage, authorID: UUID().uuidString, dateCreated: .now, clickCount: 1)
        ]
    }
}

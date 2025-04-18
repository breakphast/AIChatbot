//
//  UserModel.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/22/25.
//

import SwiftUI
import SwiftfulFirestore
import IdentifiableByString

struct UserModel: Codable, StringIdentifiable {
    var id: String {
        userID
    }
    let userID: String
    let email: String?
    let isAnonymous: Bool?
    let creationDate: Date?
    let creationVersion: String?
    let lastSignInDate: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    let characterOption: String?
    
    var profileColorConverted: Color {
        guard let profileColorHex else { return .accent }
        
        return Color(hex: profileColorHex)
    }
    
    init(
        userID: String,
        email: String? = nil,
        isAnonymous: Bool? = nil,
        creationDate: Date? = nil,
        creationVersion: String? = nil,
        lastSignInDate: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
        profileColorHex: String? = nil,
        characterOption: String? = nil
    ) {
        self.userID = userID
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.creationVersion = creationVersion
        self.lastSignInDate = lastSignInDate
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
        self.characterOption = characterOption
    }
    
    init(auth: UserAuthInfo, creationVersion: String?) {
        self.init(
            userID: auth.uid,
            email: auth.email,
            isAnonymous: auth.isAnonymous,
            creationDate: auth.creationDate,
            lastSignInDate: auth.lastSignInDate
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email
        case isAnonymous = "is_anonymous"
        case creationDate = "creation_date"
        case creationVersion = "creation_version"
        case lastSignInDate = "last_sign_in_date"
        case didCompleteOnboarding = "did_complete_onboarding"
        case profileColorHex = "profile_color_hex"
        case characterOption = "character_option"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "user_\(CodingKeys.userID.rawValue)": userID,
            "user_\(CodingKeys.email.rawValue)": email,
            "user_\(CodingKeys.isAnonymous.rawValue)": isAnonymous,
            "user_\(CodingKeys.creationDate.rawValue)": creationDate,
            "user_\(CodingKeys.creationVersion.rawValue)": creationVersion,
            "user_\(CodingKeys.lastSignInDate.rawValue)": lastSignInDate,
            "user_\(CodingKeys.didCompleteOnboarding.rawValue)": didCompleteOnboarding,
            "user_\(CodingKeys.profileColorHex.rawValue)": profileColorHex,
            "user_\(CodingKeys.characterOption.rawValue)": characterOption
        ]
        
        return dict.compactMapValues({ $0 })
    }
    
    static var mock: Self {
        mocks[0]
    }
        
    static var mocks: [Self] {
        let now = Date()
        return [
            UserModel(
                userID: "user1",
                creationDate: now,
                didCompleteOnboarding: true,
                profileColorHex: "#33A1FF",
                characterOption: "Alien"
            ),
            UserModel(
                userID: "user2",
                creationDate: now.addingTimeInterval(-86400),
                didCompleteOnboarding: false,
                profileColorHex: "#FF5733",
                characterOption: "Alien"
            ),
            UserModel(
                userID: "user3",
                creationDate: now.addingTimeInterval(-604800),
                didCompleteOnboarding: true,
                profileColorHex: "#7DFF33",
                characterOption: "Alien"
            )
        ]
    }
}

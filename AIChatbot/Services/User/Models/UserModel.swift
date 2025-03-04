//
//  UserModel.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/22/25.
//

import SwiftUI

struct UserModel: Codable {
    let userID: String
    let email: String?
    let isAnonymous: Bool?
    let creationDate: Date?
    let creationVersion: String?
    let lastSignInDate: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    
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
        profileColorHex: String? = nil
    ) {
        self.userID = userID
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.creationVersion = creationVersion
        self.lastSignInDate = lastSignInDate
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
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
                profileColorHex: "#33A1FF"
            ),
            UserModel(
                userID: "user2",
                creationDate: now.addingTimeInterval(-86400),
                didCompleteOnboarding: false,
                profileColorHex: "#FF5733"
            ),
            UserModel(
                userID: "user3",
                creationDate: now.addingTimeInterval(-604800),
                didCompleteOnboarding: true,
                profileColorHex: "#7DFF33"
            )
        ]
    }
}

//
//  UserModel.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/22/25.
//

import SwiftUI

struct UserModel {
    let userID: String
    let dateCreated: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    
    var profileColorConverted: Color {
        guard let profileColorHex else { return .accent }
        
        return Color(hex: profileColorHex)
    }
    
    init(
        userID: String,
        dateCreated: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
        profileColorHex: String? = nil
    ) {
        self.userID = userID
        self.dateCreated = dateCreated
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }
    
    static var mock: Self {
        mocks[0]
    }
        
    static var mocks: [Self] {
        let now = Date()
        return [
            UserModel(
                userID: "user1",
                dateCreated: now,
                didCompleteOnboarding: true,
                profileColorHex: "#33A1FF"
            ),
            UserModel(
                userID: "user2",
                dateCreated: now.addingTimeInterval(-86400),
                didCompleteOnboarding: false,
                profileColorHex: "#FF5733"
            ),
            UserModel(
                userID: "user3",
                dateCreated: now.addingTimeInterval(-604800),
                didCompleteOnboarding: true,
                profileColorHex: "#7DFF33"
            )
        ]
    }
}

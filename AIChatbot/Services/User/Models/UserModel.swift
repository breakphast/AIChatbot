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
        [
            UserModel(
                userID: "user_1",
                dateCreated: Date(),
                didCompleteOnboarding: true,
                profileColorHex: "#33FF57"
            ),
            UserModel(
                userID: "user_2",
                dateCreated: Date().addingTimeInterval(-86400), // 1 day ago
                didCompleteOnboarding: false,
                profileColorHex: "#FF5733"
            ),
            UserModel(
                userID: "user_3",
                dateCreated: Date().addingTimeInterval(-604800), // 1 week ago
                didCompleteOnboarding: nil,
                profileColorHex: "#3357FF"
            )
        ]
    }
}

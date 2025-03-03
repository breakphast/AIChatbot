//
//  UserAuthInfo+Firebase.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/2/25.
//

import Foundation
import FirebaseAuth

extension UserAuthInfo {
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.isAnonymous = user.isAnonymous
        self.creationDate = user.metadata.creationDate
        self.lastSignInDate = user.metadata.lastSignInDate
    }
}

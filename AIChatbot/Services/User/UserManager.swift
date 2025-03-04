//
//  UserManager.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/3/25.
//

import SwiftUI
import FirebaseFirestore

struct FirebaseUserService: UserService {
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func saveUser(user: UserModel) throws {
        try collection.document(user.userID).setData(from: user, merge: true)
    }
}

@MainActor
@Observable
class UserManager {
    private let service: UserService
    private(set) var currentUser: UserModel?
    
    init(service: UserService) {
        self.service = service
        self.currentUser = nil
    }
    
    func login(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        
        try service.saveUser(user: user)
    }
}

protocol UserService: Sendable {
    func saveUser(user: UserModel) throws
}

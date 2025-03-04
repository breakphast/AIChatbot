//
//  FirebaseUserService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/4/25.
//

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseUserService: RemoteUserService {
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func saveUser(user: UserModel) async throws {
        try await collection.setDocument(document: user)
    }
    
    func markOnboardingCompleted(userID: String, profileColorHex: String) async throws {
        try await collection.updateDocument(id: userID, dict: [
            UserModel.CodingKeys.didCompleteOnboarding.rawValue: true,
            UserModel.CodingKeys.profileColorHex.rawValue: profileColorHex
        ])
    }
    
    func streamUser(userID: String) -> AsyncThrowingStream<UserModel, Error> {
        collection.streamDocument(id: userID)
    }
    
    func deleteUser(userID: String) async throws {
        try await collection.deleteDocument(id: userID)
    }
}

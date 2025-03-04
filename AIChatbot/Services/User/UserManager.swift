//
//  UserManager.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/3/25.
//

import SwiftUI
import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseUserService: UserService {
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

struct MockUserService: UserService {
    let currentUser: UserModel?
    
    init(user: UserModel? = nil) {
        self.currentUser = user
    }
    
    func saveUser(user: UserModel) async throws {
        
    }
    
    func markOnboardingCompleted(userID: String, profileColorHex: String) async throws {
        
    }
    
    func streamUser(userID: String) -> AsyncThrowingStream<UserModel, any Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
            }
        }
    }
    
    func deleteUser(userID: String) async throws {
        
    }
}

@MainActor
@Observable
class UserManager {
    private let service: UserService
    private(set) var currentUser: UserModel?
    private var currentUserListener: ListenerRegistration?
    
    init(service: UserService) {
        self.service = service
        self.currentUser = nil
    }
    
    func login(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        
        try await service.saveUser(user: user)
        addCurrentUserListener(userID: auth.uid)
    }
    
    private func addCurrentUserListener(userID: String) {
        Task {
            do {
                for try await value in service.streamUser(userID: userID) {
                    self.currentUser = value
                    print("Successfully attached user listener \(value.userID)")
                }
            } catch {
                print("Error attaching user listener: \(error)")
            }
        }
    }
    
    func markOnboardingCompletedForCurrentUser(profileColorHex: String) async throws {
        let uid = try currentUserID()
        try await service.markOnboardingCompleted(userID: uid, profileColorHex: profileColorHex)
    }
    
    func signOut() {
        currentUserListener?.remove()
        currentUserListener = nil
        currentUser = nil
    }
    
    func deleteCurrentUser() async throws {
        let uid = try currentUserID()
        
        try await service.deleteUser(userID: uid)
    }
    
    private func currentUserID() throws -> String {
        guard let uid = currentUser?.userID else {
            throw UserManagerError.noUserID
        }
        
        return uid
    }
    
    enum UserManagerError: LocalizedError {
        case noUserID
    }
}

protocol UserService: Sendable {
    func saveUser(user: UserModel) async throws
    func markOnboardingCompleted(userID: String, profileColorHex: String) async throws
    func streamUser(userID: String) -> AsyncThrowingStream<UserModel, Error>
    func deleteUser(userID: String) async throws
}

//
//  UserManager.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/3/25.
//

import SwiftUI
import FirebaseFirestore
import SwiftfulFirestore

@MainActor
@Observable
class UserManager {
    private let remote: RemoteUserService
    private let local: LocalUserPersistence
    private(set) var currentUser: UserModel?
    private var currentUserListener: ListenerRegistration?
    
    init(services: UserServices) {
        self.remote = services.remote
        self.local = services.local
        self.currentUser = local.getCurrentUser()
    }
    
    func login(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        try await remote.saveUser(user: user)
        addCurrentUserListener(userID: auth.uid)
    }
    
    private func addCurrentUserListener(userID: String) {
        Task {
            do {
                for try await value in remote.streamUser(userID: userID) {
                    self.currentUser = value
                    self.saveCurrentUserLocally()
                    print("Successfully attached user listener \(value.userID)")
                }
            } catch {
                print("Error attaching user listener: \(error)")
            }
        }
    }
    
    private func saveCurrentUserLocally() {
        Task {
            do {
                try local.saveCurrentUser(user: currentUser)
                print("Success saved current user locally")
            } catch {
                print("Error saving current user locally: \(error)")
            }
        }
    }
    
    func markOnboardingCompletedForCurrentUser(profileColorHex: String) async throws {
        let uid = try currentUserID()
        try await remote.markOnboardingCompleted(userID: uid, profileColorHex: profileColorHex)
    }
    
    func signOut() {
        currentUserListener?.remove()
        currentUserListener = nil
        currentUser = nil
    }
    
    func deleteCurrentUser() async throws {
        let uid = try currentUserID()
        
        try await remote.deleteUser(userID: uid)
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

protocol RemoteUserService: Sendable {
    func saveUser(user: UserModel) async throws
    func markOnboardingCompleted(userID: String, profileColorHex: String) async throws
    func streamUser(userID: String) -> AsyncThrowingStream<UserModel, Error>
    func deleteUser(userID: String) async throws
}

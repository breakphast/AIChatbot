//
//  MockUserService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/4/25.
//

import SwiftUI

@MainActor
class MockUserService: RemoteUserService {
    @Published var currentUser: UserModel?
    
    init(user: UserModel? = nil) {
        self.currentUser = user
    }
    
    func saveUser(user: UserModel) async throws {
        currentUser = user
    }
    
    func markOnboardingCompleted(userID: String, profileColorHex: String) async throws {
        guard let currentUser else {
            throw URLError(.unknown)
        }
        
        self.currentUser = UserModel(
            userID: currentUser.userID,
            email: currentUser.email,
            isAnonymous: currentUser.isAnonymous,
            creationDate: currentUser.creationDate,
            creationVersion: currentUser.creationVersion,
            lastSignInDate: currentUser.lastSignInDate,
            didCompleteOnboarding: currentUser.didCompleteOnboarding,
            profileColorHex: currentUser.profileColorHex
        )
    }
    
    func streamUser(userID: String) -> AsyncThrowingStream<UserModel, any Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
            }
            
            Task {
                for await value in $currentUser.values {
                    if let value {
                        continuation.yield(value)
                    }
                }
            }
        }
    }
    
    func deleteUser(userID: String) async throws {
        currentUser = nil
    }
}

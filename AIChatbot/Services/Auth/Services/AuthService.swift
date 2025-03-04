//
//  authManager.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/2/25.
//

import SwiftUI
import Firebase

protocol AuthService: Sendable {
    func getAuthenticatedUser() -> UserAuthInfo?
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signOut() throws
    func deleteAccount() async throws
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?>
}

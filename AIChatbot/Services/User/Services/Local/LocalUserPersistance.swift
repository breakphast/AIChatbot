//
//  LocalUserPersistence.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/4/25.
//

@MainActor
protocol LocalUserPersistence {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(user: UserModel?) throws
}

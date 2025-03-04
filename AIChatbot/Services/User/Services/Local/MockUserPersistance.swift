//
//  MockUserPersistence.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/4/25.
//

struct MockUserPersistence: LocalUserPersistence {
    let currentUser: UserModel?
    
    init(user: UserModel? = nil) {
        self.currentUser = user
    }
    
    func getCurrentUser() -> UserModel? {
        currentUser
    }
    
    func saveCurrentUser(user: UserModel?) throws {
        
    }
}

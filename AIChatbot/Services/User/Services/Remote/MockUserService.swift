//
//  MockUserService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/4/25.
//

struct MockUserService: RemoteUserService {
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

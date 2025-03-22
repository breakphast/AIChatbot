//
//  ProductionUserServices.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/4/25.
//

struct ProductionUserServices: UserServices {
    let remote: RemoteUserService = FirebaseUserService()
    let local: LocalUserPersistence = FileManagerUserPersistence()
}

@MainActor
protocol UserServices {
    var remote: RemoteUserService { get }
    var local: LocalUserPersistence { get }
}

@MainActor
struct MockUserServices: UserServices {
    let remote: RemoteUserService
    let local: LocalUserPersistence
    
    init(user: UserModel? = nil) {
        self.remote = MockUserService(user: user)
        self.local = MockUserPersistence(user: user)
    }
}

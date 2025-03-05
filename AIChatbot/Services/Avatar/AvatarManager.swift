//
//  AvatarManager.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/4/25.
//

import SwiftUI
import FirebaseFirestore
import SwiftfulFirestore

@MainActor
@Observable
class AvatarManager {
    private let service: AvatarService
    
    init(service: AvatarService) {
        self.service = service
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await service.createAvatar(avatar: avatar, image: image)
    }
}

protocol AvatarService: Sendable {
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
}

struct MockAvatarService: AvatarService {
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        
    }
}

struct FirebaseAvatarService: AvatarService {
    var collection: CollectionReference {
        Firestore.firestore().collection("avatars")
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        let path = "avatars/\(avatar.avatarID)"
        let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
        
        var avatar = avatar
        avatar.updateProfileImage(imageName: url.absoluteString)
        
        try await collection.setDocument(document: avatar)
     }
}

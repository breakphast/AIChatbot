//
//  FirebaseAvatarService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/4/25.
//

import SwiftUI
import FirebaseFirestore

struct FirebaseAvatarService: RemoteAvatarService {
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
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await collection.getDocument(id: id)
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await collection
            .limit(to: 50)
            .getAllDocuments()
            .shuffled()
            .first(upTo: 5) ?? []
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await collection
            .order(by: AvatarModel.CodingKeys.clickCount.rawValue, descending: true)
            .limit(to: 200)
            .getAllDocuments()
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await collection
            .whereField(AvatarModel.CodingKeys.characterOption.rawValue, isEqualTo: category.rawValue)
            .limit(to: 200)
            .getAllDocuments()
    }
    
    func getAvatarsForAuthor(userID: String) async throws -> [AvatarModel] {
        try await collection
            .whereField(AvatarModel.CodingKeys.authorID.rawValue, isEqualTo: userID)
            .order(by: AvatarModel.CodingKeys.dateCreated.rawValue, descending: true)
            .getAllDocuments()
    }
    
    func removeAuthorIDFromAvatar(avatarID: String) async throws {
        try await collection.document(avatarID).updateData([
            AvatarModel.CodingKeys.authorID.rawValue: NSNull()
        ])
    }
    
    func removeAuthorIDFromAllAvatars(userID: String) async throws {
        let avatars = try await getAvatarsForAuthor(userID: userID)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for avatar in avatars {
                group.addTask {
                    try await removeAuthorIDFromAvatar(avatarID: avatar.id)
                }
            }
            
            try await group.waitForAll()
        }
    }
    
    func incrementAvatarClickCount(avatarID: String) async throws {
        try await collection.document(avatarID).updateData([
            AvatarModel.CodingKeys.clickCount.rawValue: FieldValue.increment(Int64(1))
        ])
    }
}

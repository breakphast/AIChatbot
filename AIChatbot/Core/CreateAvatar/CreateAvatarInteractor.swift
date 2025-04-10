//
//  CreateAvatarInteractor 2.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol CreateAvatarInteractor {
    func trackEvent(event: LoggableEvent)
    func generateImage(input: String) async throws -> UIImage
    func getAuthID() throws -> String
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
    var currentUser: UserModel? { get }
}

extension CoreInteractor: CreateAvatarInteractor { }

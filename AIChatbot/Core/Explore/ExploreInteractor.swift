//
//  ExploreInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI
import CustomRouting

@MainActor
protocol ExploreInteractor {
    var categoryRowTestType: CategoryRowTestOption { get }
    var auth: UserAuthInfo? { get }
    var createAccountTest: Bool { get }
    
    func trackEvent(event: LoggableEvent)
    func getFeaturedAvatars() async throws -> [AvatarModel]
    func getPopularAvatars() async throws -> [AvatarModel]
    func canRequestAuthorization() async -> Bool
    func schedulePushNotificationsForTheNextWeek()
    func requestAuthorization() async throws -> Bool
}

extension CoreInteractor: ExploreInteractor { }

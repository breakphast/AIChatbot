//
//  OnbInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/9/25.
//

import SwiftUI

@MainActor
struct OnbInteractor {
    private let logManager: LogManager
    private let appState: AppState
    private let userManager: UserManager
    private let abTestManager: ABTestManager
    private let authManager: AuthManager
    private let purchaseManager: PurchaseManager
    
    init(container: DependencyContainer) {
        self.userManager = container.resolve(UserManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
        self.appState = container.resolve(AppState.self)!
        self.authManager = container.resolve(AuthManager.self)!
        self.purchaseManager = container.resolve(PurchaseManager.self)!
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func updateAppState(showTabBar: Bool) {
        appState.updateViewState(showTabBarView: showTabBar)
    }
    
    var onboardingCommunityTest: Bool {
        abTestManager.activeTests.onboardingCommunityTest
    }
    
    func markOnboardingCompletedForCurrentUser(profileColorHex: String) async throws {
        try await userManager.markOnboardingCompletedForCurrentUser(profileColorHex: profileColorHex)
    }
    
    func login(user: UserAuthInfo, isNewUser: Bool) async throws {
        try await userManager.login(auth: user, isNewUser: isNewUser)
        try await purchaseManager.login(
            userID: user.uid,
            attributes: PurchaseProfileAttributes(
                email: user.email,
                firebaseAppInstanceID: FirebaseAnalyticsService.appInstanceID,
                mixpanelDistinctID: MixpanelService.distinctID
            )
        )
    }
    
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInApple()
    }
}

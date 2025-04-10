//
//  OnbInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/9/25.
//

import SwiftUI

@MainActor
struct OnbInteractor: GlobalInteractor {
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
    
    func trackEvent(eventName: String, parameters: [String: Any]? = nil, type: LogType = .analytic) {
        logManager.trackEvent(eventName: eventName, parameters: parameters, type: type)
    }
    
    func trackEvent(event: AnyLoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func trackEvent(event: LoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func trackScreenEvent(event: LoggableEvent) {
        logManager.trackScreenView(event: event)
    }
    
    func updateAppState(showTabBar: Bool) {
        appState.updateViewState(showTabBarView: showTabBar)
    }
    
    var onboardingCommunityTest: Bool {
        abTestManager.activeTests.onboardingCommunityTest
    }
    
    var onboardingCategoryTest: Bool {
        abTestManager.activeTests.onboardingCategoryTest
    }
    
    func markOnboardingCompletedForCurrentUser(profileColorHex: String, category: String) async throws {
        try await userManager.markOnboardingCompletedForCurrentUser(
            profileColorHex: profileColorHex,
            category: category
        )
    }
    
    func login(user: UserAuthInfo, isNewUser: Bool) async throws {
        try await userManager.login(auth: user, isNewUser: isNewUser)
        try await purchaseManager.logIn(
            userId: user.uid,
            userAttributes: PurchaseProfileAttributes(
                email: user.email,
                mixpanelDistinctId: Constants.mixpanelDistinctID,
                firebaseAppInstanceId: Constants.firebaseAnalyticsAppInstanceID
            )
        )
    }
    
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInApple()
    }
}

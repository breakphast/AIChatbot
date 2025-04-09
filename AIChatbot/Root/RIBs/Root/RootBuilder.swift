//
//  RootBuilder.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/9/25.
//

import SwiftUI

@MainActor
struct RootBuilder: Buildable {
    let interactor: RootInteractor
    let loggedInRIB: CoreBuilder
    
    func build() -> AnyView {
        appView().any()
    }
    
    func appView() -> some View {
        AppView(
            presenter: AppPresenter(
                interactor: interactor
            ),
            tabBarView: {
                loggedInRIB.build()            },
            onboardingView: {
                Text("Welcome view")
            }
        )
    }
}

@MainActor
struct RootInteractor {
    private let authManager: AuthManager
    private let purchaseManager: PurchaseManager
    private let appState: AppState
    private let userManager: UserManager
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.purchaseManager = container.resolve(PurchaseManager.self)!
        self.appState = container.resolve(AppState.self)!
    }
    
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    var showTabBar: Bool {
        appState.showTabBar
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInAnonymously()
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
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}

@MainActor
struct RootRouter: GlobalRouter {
    let router: Router
    let builder: RootBuilder
}

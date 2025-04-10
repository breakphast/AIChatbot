//
//  Dependencies.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/27/25.
//

import SwiftUI
import SwiftfulRouting

typealias RouterView = SwiftfulRouting.RouterView
typealias AlertType = SwiftfulRouting.DialogOption
typealias Router = SwiftfulRouting.AnyRouter

import SwiftfulAuthenticating
import SwiftfulAuthenticatingFirebase

typealias UserAuthInfo = SwiftfulAuthenticating.UserAuthInfo
typealias AuthManager = SwiftfulAuthenticating.AuthManager
typealias MockAuthService = SwiftfulAuthenticating.MockAuthService

extension AuthLogType {
    var type: LogType {
        switch self {
        case .info:
            return .info
        case .analytic:
            return .analytic
        case .warning:
            return .warning
        case .severe:
            return .severe
        }
    }
}

extension LogManager: AuthLogger {
    func trackEvent(event: any AuthLogEvent) {
        trackEvent(eventName: event.eventName, parameters: event.parameters, type: event.type.type)
    }
}

@MainActor
struct Dependencies {
    let container: DependencyContainer
    let logManager: LogManager

    // swiftlint:disable:next function_body_length
    init(config: BuildConfiguration) {
        let authManager: AuthManager
        let userManager: UserManager
        let abTestManager: ABTestManager
        let purchaseManager: PurchaseManager
        let appState: AppState
        
        let aiService: AIService
        let remoteAvatarService: RemoteAvatarService
        let localAvatarService: LocalAvatarPersistence
        let chatService: ChatService
        
        switch config {
        case .mock(isSignedIn: let isSignedIn):
            logManager = LogManager(services: [
                ConsoleService(printParameters: false)
            ])
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil), logger: logManager)
            userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil), logManager: logManager)
            aiService = MockAIService()
            localAvatarService = MockLocalAvatarPersistence()
            remoteAvatarService = MockAvatarService()
            chatService = MockChatService()
            
            let isInOnboardingCommunityTest = ProcessInfo.processInfo.arguments.contains("ONBCMMTEST")
            let abTestService = MockABTestService(
                onboardingCommunityTest: isInOnboardingCommunityTest,
                paywallTest: .custom
            )
            
            abTestManager = ABTestManager(service: abTestService, logManager: logManager)
            purchaseManager = PurchaseManager(service: MockPurchaseService(), logManager: logManager)
            appState = AppState(showTabBar: isSignedIn)
        case .dev:
            logManager = LogManager(services: [
                ConsoleService(printParameters: true),
                FirebaseAnalyticsService(),
                MixpanelService(token: Keys.mixpanelToken),
                FirebaseCrashlyticsService()
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logger: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            aiService = OpenAIService()
            localAvatarService = SwiftDataLocalAvatarPersistence()
            remoteAvatarService = MockAvatarService()
            chatService = FirebaseChatService()
            
            abTestManager = ABTestManager(service: LocalABTestService(), logManager: logManager)
            purchaseManager = PurchaseManager(
                service: RevenueCatPurchaseService(apiKey: Keys.revenueCatApiKey),
                logManager: logManager
            )
            appState = AppState()
        case .prod:
            logManager = LogManager(services: [
                FirebaseAnalyticsService(),
                MixpanelService(token: Keys.mixpanelToken),
                FirebaseCrashlyticsService()
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logger: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            abTestManager = ABTestManager(service: FirebaseABTestService(), logManager: logManager)
            purchaseManager = PurchaseManager(service: StoreKitPurchaseService(), logManager: logManager)
            appState = AppState()
            
            aiService = OpenAIService()
            localAvatarService = SwiftDataLocalAvatarPersistence()
            remoteAvatarService = FirebaseAvatarService()
            chatService = FirebaseChatService()
        }
        
        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(LogManager.self, service: logManager)
        container.register(ABTestManager.self, service: abTestManager)
        container.register(PurchaseManager.self, service: purchaseManager)
        container.register(AppState.self, service: appState)
        
        container.register(AIService.self, service: aiService)
        container.register(LocalAvatarPersistence.self, service: localAvatarService)
        container.register(RemoteAvatarService.self, service: remoteAvatarService)
        container.register(ChatService.self, service: chatService)
        self.container = container
    }
}

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(LogManager(services: []))
    }
}

@MainActor
class DevPreview {
    static let shared = DevPreview()
    
    var container: DependencyContainer {
        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(LogManager.self, service: logManager)
        container.register(ABTestManager.self, service: abTestManager)
        container.register(PurchaseManager.self, service: purchaseManager)
        container.register(AppState.self, service: appState)
        
        container.register(AIService.self, service: aiService)
        container.register(LocalAvatarPersistence.self, service: localAvatarService)
        container.register(RemoteAvatarService.self, service: remoteAvatarService)
        container.register(ChatService.self, service: chatService)
        return container
    }
    let authManager: AuthManager
    let userManager: UserManager
    let logManager: LogManager
    let abTestManager: ABTestManager
    let purchaseManager: PurchaseManager
    let appState: AppState
    
    let aiService: AIService
    let remoteAvatarService: RemoteAvatarService
    let localAvatarService: LocalAvatarPersistence
    let chatService: ChatService
    
    init(isSignedIn: Bool = true) {
        self.authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil))
        self.userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))
        self.logManager = LogManager(services: [])
        self.abTestManager = ABTestManager(service: MockABTestService())
        self.purchaseManager = PurchaseManager(service: MockPurchaseService())
        self.appState = AppState()
        
        self.aiService = MockAIService()
        self.localAvatarService = MockLocalAvatarPersistence()
        self.remoteAvatarService = MockAvatarService()
        self.chatService = MockChatService()
    }
}

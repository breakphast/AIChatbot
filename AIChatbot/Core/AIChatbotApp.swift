//
//  AIChatbotApp.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/10/25.
//

import SwiftUI
import Firebase

@main
struct AIChatCourseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(delegate.dependencies.pushManager)
                .environment(delegate.dependencies.aiManager)
                .environment(delegate.dependencies.avatarManager)
                .environment(delegate.dependencies.userManager)
                .environment(delegate.dependencies.authManager)
                .environment(delegate.dependencies.chatManager)
                .environment(delegate.dependencies.logManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        let config: BuildConfiguration
        
        #if MOCK
        config = .mock(isSignedIn: true)
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif
         
        config.configure()
        dependencies = Dependencies(config: config)
        return true
    }
}

enum BuildConfiguration {
    case mock(isSignedIn: Bool = true), dev, prod
    
    func configure() {
        switch self {
        case .mock:
            break
        case .dev:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        case .prod:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        }
    }
}

@MainActor
struct Dependencies {
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let authManager: AuthManager
    let userManager: UserManager
    let chatManager: ChatManager
    let logManager: LogManager
    let pushManager: PushManager
    
    init(config: BuildConfiguration) {
        switch config {
        case .mock(isSignedIn: let isSignedIn):
            logManager = LogManager(services: [
                ConsoleService(printParameters: false)
            ])
            aiManager = AIManager(service: MockAIService())
            avatarManager = AvatarManager(service: MockAvatarService(), local: MockLocalAvatarPersistence())
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil), logManager: logManager)
            userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil), logManager: logManager)
            chatManager = ChatManager(service: MockChatService())
        case .dev:
            logManager = LogManager(
                services: [
                    ConsoleService(printParameters: false),
                    FirebaseAnalyticsService(),
                    MixpanelService(token: Keys.mixpanelToken),
                    FirebaseCrashlyticsService()
                ]
            ) 
            aiManager = AIManager(service: OpenAIService())
            avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistence())
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            chatManager = ChatManager(service: FirebaseChatService())
        case .prod:
            logManager = LogManager(
                services: [
                    FirebaseAnalyticsService(),
                    MixpanelService(token: Keys.mixpanelToken),
                    FirebaseCrashlyticsService()
                ]
            )
            aiManager = AIManager(service: OpenAIService())
            avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistence())
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            chatManager = ChatManager(service: FirebaseChatService())
        }
        
        pushManager = PushManager(logManager: logManager)
    }
}

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(PushManager())
            .environment(AppState())
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil)))
            .environment(AvatarManager(service: MockAvatarService()))
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil)))
            .environment(AIManager(service: MockAIService()))
            .environment(ChatManager(service: MockChatService()))
            .environment(LogManager(services: []))
    }
}

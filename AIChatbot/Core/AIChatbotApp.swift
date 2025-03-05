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
                .environment(delegate.dependencies.aiManager)
                .environment(delegate.dependencies.avatarManager)
                .environment(delegate.dependencies.userManager)
                .environment(delegate.dependencies.authManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        dependencies = Dependencies()
        return true
    }
}

@MainActor
struct Dependencies {
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let authManager: AuthManager
    let userManager: UserManager
    
    init() {
        aiManager = AIManager(service: OpenAIService())
        avatarManager = AvatarManager(service: FirebaseAvatarService())
        authManager = AuthManager(service: FirebaseAuthService())
        userManager = UserManager(services: ProductionUserServices())
    }
}

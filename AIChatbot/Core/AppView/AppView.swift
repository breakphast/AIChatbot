//
//  AppView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct AppView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @State var appState = AppState()
    
    var body: some View {
        AppViewBuilder(
            showTabBar: appState.showTabBar,
            tabBarView: {
                TabBarView()
            },
            onboardingView: {
                WelcomeView()
            }
        )
        .environment(appState)
        .environment(userManager)
        .onAppear {
            logManager.identifyUser(userID: "abc123", name: "desmond", email: "des@des.com")
            logManager.addUserProperties(dict: UserModel.mock.eventParameters, isHighPriority: false)
            
            logManager.trackEvent(event: Event.alpha)
            logManager.trackEvent(event: Event.beta)
            logManager.trackEvent(event: Event.gamma)
            logManager.trackEvent(event: Event.delta)
            
            let event = AnyLoggableEvent(
                eventName: "MyNewEvent",
                parameters: UserModel.mock.eventParameters,
                type: .analytic
            )
            
            logManager.trackEvent(event: event)
            logManager.trackEvent(eventName: "AnotherEventIsHere")
        }
        .task {
            await checkUserStatus()
        }
        .onChange(of: appState.showTabBar) { _, showTabBar in
            if !showTabBar {
                Task {
                    await checkUserStatus()
                }
            }
        }
    }
    
    enum Event: LoggableEvent {
        case alpha, beta, gamma, delta
        
        var eventName: String {
            switch self {
            case .alpha:
                "event_alpha"
            case .beta:
                "event_beta"
            case .gamma:
                "event_gamma"
            case .delta:
                "event_delta"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .alpha, .beta:
                return [
                    "aaa": true,
                    "bbb": 123
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .alpha:
                .info
            case .beta:
                .analytic
            case .gamma:
                .warning
            case .delta:
                .severe
            }
        }
    }
    
    private func checkUserStatus() async {
        if let user = authManager.auth {
            print("User already authenticated: \(user.uid)")
            
            do {
                try await userManager.login(auth: user, isNewUser: false)
            } catch {
                print("Failed to login to auth for existing user \(error)")
                await checkUserStatus()
            }
        } else {
            do {
                let result = try await authManager.signInAnonymously()
                print("Signed in anonymously \(result.user.uid)")
                
                try await userManager.login(auth: result.user, isNewUser: result.isNewUser)
            } catch {
                print("Failed to sign in anonymously and login: \(error)")
                await checkUserStatus()
            }
        }
    }
}

#Preview("AppView - TabBar") {
    AppView(appState: AppState(showTabBar: true))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .environment(UserManager(services: MockUserServices(user: .mock)))
}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
}

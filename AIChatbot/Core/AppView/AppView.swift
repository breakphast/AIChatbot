//
//  AppView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct AppView: View {
    @Environment(AuthManager.self) private var authManager
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
//        .environment(appState)
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
    
    private func checkUserStatus() async {
        if let user = authManager.auth {
            print("User already authenticated: \(user.uid)")
        } else {
            do {
                let result = try await authManager.signInAnonymously()
                print("Signed in anonymously \(result.user.uid)")
            } catch {
                print(error)
            }
        }
    }
}

#Preview("AppView - TabBar") {
    AppView(appState: AppState(showTabBar: true))
}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
}

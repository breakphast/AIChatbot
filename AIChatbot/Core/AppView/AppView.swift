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
            
            do {
                try await userManager.login(auth: user, isNewUser: false)
            } catch {
                print("Failed to login to auth for existing user \(error)")
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            do {
                let result = try await authManager.signInAnonymously()
                print("Signed in anonymously \(result.user.uid)")
                
                try await userManager.login(auth: result.user, isNewUser: result.isNewUser)
            } catch {
                print("Failed to sign in anonymously and login: \(error)")
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
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

//
//  AppView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct AppView: View {
    @Environment(CoreBuilder.self) private var builder
    @Environment(\.scenePhase) private var scenePhase
    
    @State var viewModel: AppViewModel
    
    var body: some View {
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: nil,
                onApplicationWillEnterForeground: { _ in
                    Task {
                        await viewModel.checkUserStatus()
                    }
                },
                onApplicationDidBecomeActive: nil,
                onApplicationWillResignActive: nil,
                onApplicationDidEnterBackground: nil,
                onApplicationWillTerminate: nil
            ),
            content: {
                AppViewBuilder(
                    showTabBar: viewModel.showTabBar,
                    tabBarView: {
                        builder.tabBarView()
                    },
                    onboardingView: {
                        builder.welcomeView()
                    }
                )
                .task {
                    await viewModel.checkUserStatus()
                }
                .onNotificationReceived(name: UIApplication.willEnterForegroundNotification, action: { _ in
                    Task {
                        await viewModel.checkUserStatus()
                    }
                })
                .task {
                    try? await Task.sleep(for: .seconds(2))
                    await viewModel.showATTPromptIfNeeded()
                }
                .onChange(of: viewModel.showTabBar) { _, showTabBar in
                    if !showTabBar {
                        Task {
                            await viewModel.checkUserStatus()
                        }
                    }
                }
            }
        )
    }
}

#Preview("AppView - TabBar") {
    let container = DevPreview.shared.container
    container.register(AppState.self, service: AppState(showTabBar: true))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return builder.appView()
        .previewEnvironment()
}

#Preview("AppView - Onboarding") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))
    container.register(AppState.self, service: AppState(showTabBar: false))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return builder.appView()
        .previewEnvironment()
}

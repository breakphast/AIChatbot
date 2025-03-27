//
//  AppView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct AppView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.scenePhase) private var scenePhase
    
    @State var viewModel: AppViewViewModel
    
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
                        TabBarView()
                    },
                    onboardingView: {
                        WelcomeView(
                            viewModel: WelcomeViewModel(
                                interactor: CoreInteractor(container: container)
                            )
                        )
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
    
    return AppView(
        viewModel: AppViewViewModel(
            interactor: CoreInteractor(container: container)
        )
    )
    .previewEnvironment()
}

#Preview("AppView - Onboarding") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))
    container.register(AppState.self, service: AppState(showTabBar: false))
    
    return AppView(
        viewModel: AppViewViewModel(
            interactor: CoreInteractor(container: container)
        )
    )
    .previewEnvironment()
}

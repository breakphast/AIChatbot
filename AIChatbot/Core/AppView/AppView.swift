//
//  AppView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct AppView<TabBarView: View, OnboardingView: View>: View {
    @State var presenter: AppPresenter
    var tabBarView: () -> TabBarView
    var onboardingView: () -> OnboardingView
    
    var body: some View {
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: nil,
                onApplicationWillEnterForeground: { _ in
                    Task {
                        await presenter.checkUserStatus()
                    }
                },
                onApplicationDidBecomeActive: nil,
                onApplicationWillResignActive: nil,
                onApplicationDidEnterBackground: nil,
                onApplicationWillTerminate: nil
            ),
            content: {
                AppViewBuilder(
                    showTabBar: presenter.showTabBar,
                    tabBarView: {
                        tabBarView()
                    },
                    onboardingView: {
                        onboardingView()
                    }
                )
                .task {
                    await presenter.checkUserStatus()
                }
                .onNotificationReceived(name: UIApplication.willEnterForegroundNotification, action: { _ in
                    Task {
                        await presenter.checkUserStatus()
                    }
                })
                .task {
                    try? await Task.sleep(for: .seconds(2))
                    await presenter.showATTPromptIfNeeded()
                }
                .onChange(of: presenter.showTabBar) { _, showTabBar in
                    if !showTabBar {
                        Task {
                            await presenter.checkUserStatus()
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
    let builder = RootBuilder(
        interactor: RootInteractor(container: container),
        loggedInRIB: {
            CoreBuilder(interactor: CoreInteractor(container: container))
        },
        loggedOutRIB: {
            OnbBuilder(interactor: OnbInteractor(container: container))
        }
    )
    
    return builder.appView()
        .previewEnvironment()
}

#Preview("AppView - Onboarding") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))
    container.register(AppState.self, service: AppState(showTabBar: false))
    let builder = RootBuilder(
        interactor: RootInteractor(container: container),
        loggedInRIB: {
            CoreBuilder(interactor: CoreInteractor(container: container))
        },
        loggedOutRIB: {
            OnbBuilder(interactor: OnbInteractor(container: container))
        }
    )
    
    return builder.appView()
        .previewEnvironment()
}

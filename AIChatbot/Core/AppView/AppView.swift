//
//  AppView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI
import AppTrackingTransparency

@MainActor
protocol AppViewInteractor {
    var auth: UserAuthInfo? { get }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func login(user: UserAuthInfo, isNewUser: Bool) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: AppViewInteractor { }

@MainActor
@Observable
class AppViewViewModel {
    private let interactor: AppViewInteractor
    
    init(interactor: AppViewInteractor) {
        self.interactor = interactor
    }
    
    func checkUserStatus() async {
        if let user = interactor.auth {
            interactor.trackEvent(event: Event.existingAuthStart)
            
            do {
                try await interactor.login(user: user, isNewUser: false)
            } catch {
                interactor.trackEvent(event: Event.existingAuthFail(error: error))
                await checkUserStatus()
            }
        } else {
            interactor.trackEvent(event: Event.anonAuthStart)
            do {
                let result = try await interactor.signInAnonymously()
                interactor.trackEvent(event: Event.anonAuthSuccess)
                
                try await interactor.login(user: result.user, isNewUser: result.isNewUser)
            } catch {
                interactor.trackEvent(event: Event.anonAuthFail(error: error))
                await checkUserStatus()
            }
        }
    }
    
    func showATTPromptIfNeeded() async {
        #if !DEBUG
        let status = await AppTrackingTransparencyHelper.requestTrackingAuthorization()
        interactor.trackEvent(event: Event.attStatus(dict: status.eventParameters))
        #endif
    }
    
    enum Event: LoggableEvent {
        case existingAuthStart
        case existingAuthFail(error: Error)
        case anonAuthStart
        case anonAuthSuccess
        case anonAuthFail(error: Error)
        case attStatus(dict: [String: Any])
        
        var eventName: String {
            switch self {
            case .existingAuthStart:    return "AppView_ExistingAuth"
            case .existingAuthFail:     return "AppView_ExistingAuth_Fail"
            case .anonAuthStart:        return "AppView_AnonAuth_Start"
            case .anonAuthSuccess:      return "AppView_AnonAuth_Success"
            case .anonAuthFail:         return "AppView_AnonAuth_Fail"
            case .attStatus:            return "AppView_ATTStatus"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .existingAuthFail(error: let error), .anonAuthFail(error: let error):
                return error.eventParameters
            case .attStatus(dict: let dict):
                return dict
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .existingAuthFail, .anonAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

struct AppView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.scenePhase) private var scenePhase
    @State var appState = AppState()
    
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
                    showTabBar: appState.showTabBar,
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
                .environment(appState)
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
                .onChange(of: appState.showTabBar) { _, showTabBar in
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
    
    return AppView(
        appState: AppState(showTabBar: true),
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
    
    return AppView(
        appState: AppState(showTabBar: true),
        viewModel: AppViewViewModel(
            interactor: CoreInteractor(container: container)
        )
    )
    .previewEnvironment()
}

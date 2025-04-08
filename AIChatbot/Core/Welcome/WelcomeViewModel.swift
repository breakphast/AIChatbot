//
//  WelcomeInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/27/25.
//

import SwiftUI

@MainActor
protocol WelcomeInteractor {
    func trackEvent(event: LoggableEvent)
    func updateAppState(showTabBar: Bool)
}

extension CoreInteractor: WelcomeInteractor { }

@MainActor
protocol WelcomeRouter {
    func showCreateAccountView(delegate: CreateAccountDelegate)
    func showOnboardingIntroView(delegate: OnboardingIntroDelegate)
}

extension CoreRouter: WelcomeRouter { }

@MainActor
@Observable
class WelcomeViewModel {
    private let interactor: WelcomeInteractor
    private let router: WelcomeRouter
    
    private(set) var imageName: String = Constants.randomImage
    
    init(interactor: WelcomeInteractor, router: WelcomeRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onGetStartedPressed() {
        router.showOnboardingIntroView(delegate: OnboardingIntroDelegate())
    }
    
    func onSignInPressed() {
        interactor.trackEvent(event: Event.signInPressed)
        
        let delegate = CreateAccountDelegate(
            title: "Sign in",
            subtitle: "Connect to an existing account.",
            onDidSignIn: { isNewUser in
                self.handleDidSignIn(isNewUser: isNewUser)
            }
        )
        router.showCreateAccountView(delegate: delegate)
    }
    
    private func handleDidSignIn(isNewUser: Bool) {
        interactor.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))
        if isNewUser {
            
        } else {
            interactor.updateAppState(showTabBar: true)
        }
    }
    
    enum Event: LoggableEvent {
        case didSignIn(isNewUser: Bool)
        case signInPressed
        
        var eventName: String {
            switch self {
            case .didSignIn:        return "WelcomeView_DidSignIn"
            case .signInPressed:    return "WelcomeView_SignIn_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .didSignIn(isNewUser: let isNewUser):
                return ["isNewUser": isNewUser]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}

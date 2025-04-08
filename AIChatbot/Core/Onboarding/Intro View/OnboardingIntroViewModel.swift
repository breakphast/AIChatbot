//
//  OnboardingIntroInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/27/25.
//

import SwiftUI

@MainActor
protocol OnboardingIntroInteractor {
    var onboardingCommunityTest: Bool { get }
    
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingIntroInteractor { }

@MainActor
protocol OnboardingIntroRouter {
    func showOnboardingCommunityView(delegate: OnboardingCommunityDelegate)
    func showOnboardingColorView(delegate: OnboardingColorDelegate)
}

extension CoreRouter: OnboardingIntroRouter { }

@MainActor
@Observable
class OnboardingIntroViewModel {
    private let interactor: OnboardingIntroInteractor
    private let router: OnboardingIntroRouter

    init(interactor: OnboardingIntroInteractor, router: OnboardingIntroRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onContinueButtonPressed() {
        if interactor.onboardingCommunityTest {
            router.showOnboardingCommunityView(delegate: OnboardingCommunityDelegate())
        } else {
            router.showOnboardingColorView(delegate: OnboardingColorDelegate())
        }
    }
    
    enum Event: LoggableEvent {
        case communityView
        case colorView
        
        var eventName: String {
            switch self {
            case .communityView:    return "OnboardingIntro_MoveTo_CommunityView"
            case .colorView:        return "OnboardingIntro_MoveTo_ColorView"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
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

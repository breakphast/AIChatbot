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
@Observable
class OnboardingIntroViewModel {
    private let interactor: OnboardingIntroInteractor

    init(interactor: OnboardingIntroInteractor) {
        self.interactor = interactor
    }
    
    func onContinueButtonPressed(path: Binding<[OnboardingPathOption]>) {
        if interactor.onboardingCommunityTest {
            path.wrappedValue.append(.community)
        } else {
            path.wrappedValue.append(.color)
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

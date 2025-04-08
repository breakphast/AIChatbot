//
//  OnboardingCompletedInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/27/25.
//

import SwiftUI

@MainActor
@Observable
class OnboardingCompletedPresenter {
    private let interactor: OnboardingCompletedInteractor
    private let router: OnboardingCompletedRouter
    
    var isCompletingProfileSetup = false
    
    init(interactor: OnboardingCompletedInteractor, router: OnboardingCompletedRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onFinishButtonPressed(selectedColor: Color) {
        interactor.trackEvent(event: Event.finishStart)
        isCompletingProfileSetup = true
        
        Task {
            do {
                let hex = selectedColor.asHex()
                try await interactor.markOnboardingCompletedForCurrentUser(profileColorHex: hex)
                interactor.trackEvent(event: Event.finishSuccess(hex: hex))
                
                isCompletingProfileSetup = false
                
                interactor.updateAppState(showTabBar: true)
            } catch {
                router.showAlert(error: error)
                interactor.trackEvent(event: Event.finishFail(error: error))
            }
        }
    }
    
    enum Event: LoggableEvent {
        case finishStart
        case finishSuccess(hex: String)
        case finishFail(error: Error)
        
        var eventName: String {
            switch self {
            case .finishStart:      return "OnboardingCompletedView_Finish_Start"
            case .finishSuccess:    return "OnboardingCompletedView_Finish_Success"
            case .finishFail:       return "OnboardingCompletedView_Finish_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .finishSuccess(hex: let hex):
                return [
                    "profile_color_hex": hex
                ]
            case .finishFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .finishFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

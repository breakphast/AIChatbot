//
//  OnboardingCompletedInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/27/25.
//

import SwiftUI

@MainActor
protocol OnboardingCompletedInteractor {
    func updateAppState(showTabBar: Bool)
    func markOnboardingCompletedForCurrentUser(profileColorHex: String) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingCompletedInteractor { }

@MainActor
@Observable
class OnboardingCompletedViewModel {
    private let interactor: OnboardingCompletedInteractor
    
    var isCompletingProfileSetup = false
    var showAlert: AnyAppAlert?
    
    init(interactor: OnboardingCompletedInteractor) {
        self.interactor = interactor
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
                showAlert = AnyAppAlert(error: error)
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

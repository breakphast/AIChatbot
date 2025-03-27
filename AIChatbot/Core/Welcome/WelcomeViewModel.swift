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
}

extension CoreInteractor: WelcomeInteractor { }

@MainActor
@Observable
class WelcomeViewModel {
    private let interactor: WelcomeInteractor
    
    private(set) var imageName: String = Constants.randomImage
    var showSignInView = false
    
    init(interactor: WelcomeInteractor) {
        self.interactor = interactor
    }
    
    func onSignInPressed() {
        interactor.trackEvent(event: Event.signInPressed)
        showSignInView = true
    }
    
    func handleDidSignIn(isNewUser: Bool, updateViewState: @escaping () -> Void) {
        interactor.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))
        if isNewUser {
            
        } else {
            updateViewState()
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

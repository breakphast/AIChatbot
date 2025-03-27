//
//  AppViewInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/27/25.
//

import SwiftUI
import AppTrackingTransparency

@MainActor
protocol AppViewInteractor {
    var auth: UserAuthInfo? { get }
    var showTabBar: Bool { get }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func login(user: UserAuthInfo, isNewUser: Bool) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: AppViewInteractor { }

@MainActor
@Observable
class AppViewModel {
    private let interactor: AppViewInteractor
    
    var showTabBar: Bool {
        interactor.showTabBar
    }
    
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

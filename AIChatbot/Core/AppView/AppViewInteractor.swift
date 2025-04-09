//
//  AppViewInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
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

extension RootInteractor: AppViewInteractor { }

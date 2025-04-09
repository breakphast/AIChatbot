//
//  SettingsInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI
import SwiftfulUtilities

@MainActor
protocol SettingsInteractor {
    var auth: UserAuthInfo? { get }
    
    func signOut() async throws
    func getAuthID() throws -> String
    func trackEvent(event: LoggableEvent)
    func deleteAccount(userID: String) async throws
    func updateAppState(showTabBar: Bool)
}

extension CoreInteractor: SettingsInteractor { }

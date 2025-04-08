//
//  DevSettingsInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI
import SwiftfulUtilities

@MainActor
protocol DevSettingsInteractor {
    var activeTests: ActiveABTests { get }
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    
    func override(updatedTests: ActiveABTests) throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: DevSettingsInteractor { }

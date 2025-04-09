//
//  CreateAccountInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol CreateAccountInteractor {
    func trackEvent(event: LoggableEvent)
    func login(user: UserAuthInfo, isNewUser: Bool) async throws
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
}

extension CoreInteractor: CreateAccountInteractor { }
extension OnbInteractor: CreateAccountInteractor { }

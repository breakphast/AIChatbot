//
//  ChatRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol ChatRouter {
    func showPaywallView()
    func showAlert(error: Error)
    func showAlert(_ option: AlertType, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?)
    func showSimpleAlert(title: String, subtitle: String?)
    func showProfileModal(avatar: AvatarModel, onXMarkPressed: @escaping () -> Void)
    func dismissModal()
    func dismissScreen()
}

extension CoreRouter: ChatRouter { }

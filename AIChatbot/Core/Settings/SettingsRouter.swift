//
//  SettingsRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI
import SwiftfulUtilities

@MainActor
protocol SettingsRouter {
    func showRatingsModal(onYesPressed: @escaping () -> Void, onNoPressed: @escaping () -> Void)
    func dismissModal()
    func dismissScreen()
    func showAlert(error: Error)
    func showAlert(_ option: DialogOption, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?)
    func showCreateAccountView(delegate: CreateAccountDelegate, onDismiss: (() -> Void)?)
    func showAboutView(delegate: AboutDelegate)
}

extension CoreRouter: SettingsRouter { }

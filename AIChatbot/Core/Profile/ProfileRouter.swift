//
//  ProfileRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol ProfileRouter {
    func showSettingsView()
    func showSimpleAlert(title: String, subtitle: String?)
    func showChatView(delegate: ChatViewDelegate)
    func showCreateAvatarView(onDismiss: @escaping () -> Void)
}

extension CoreRouter: ProfileRouter { }

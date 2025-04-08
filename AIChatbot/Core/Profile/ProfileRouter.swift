//
//  ProfileRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI
import CustomRouting

@MainActor
protocol ProfileRouter {
    func showSettingsView()
    func showSimpleAlert(title: String, subtitle: String?)
    func showChatView(delegate: ChatViewDelegate)
    func showCreateAvatarView(onDisappear: @escaping () -> Void)
}

extension CoreRouter: ProfileRouter { }

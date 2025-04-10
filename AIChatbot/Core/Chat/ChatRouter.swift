//
//  ChatRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol ChatRouter: GlobalRouter {
    func showPaywallView()
    func showProfileModal(avatar: AvatarModel, onXMarkPressed: @escaping () -> Void)
}

extension CoreRouter: ChatRouter { }

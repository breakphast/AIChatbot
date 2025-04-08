//
//  ExploreRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol ExploreRouter {
    // Segues
    func showCategoryListView(delegate: CategoryListDelegate)
    func showChatView(delegate: ChatViewDelegate)
    func showCreateAccountView(delegate: CreateAccountDelegate, onDisappear: (() -> Void)?)
    func showDevSettingsView()
    
    // Modals
    func showPushNotificationModal(onEnablePressed: @escaping () -> Void, onCancelPressed: @escaping () -> Void)
    func dismissModal()
}

extension CoreRouter: ExploreRouter { }

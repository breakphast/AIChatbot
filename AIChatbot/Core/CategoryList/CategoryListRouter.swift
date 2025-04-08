//
//  CategoryListRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol CategoryListRouter {
    func showChatView(delegate: ChatViewDelegate)
    func showAlert(error: Error)
}

extension CoreRouter: CategoryListRouter { }

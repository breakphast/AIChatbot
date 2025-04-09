//
//  ChatsRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol ChatsRouter {
    func showChatView(delegate: ChatViewDelegate)
}

extension CoreRouter: ChatsRouter { }

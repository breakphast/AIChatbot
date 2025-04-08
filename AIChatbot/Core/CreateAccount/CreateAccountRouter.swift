//
//  CreateAccountRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol CreateAccountRouter {
    func dismissScreen()
}

extension CoreRouter: CreateAccountRouter { }

//
//  PaywallRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI
import StoreKit

@MainActor
protocol PaywallRouter {
    func showAlert(error: Error)
    func dismissScreen()
}

extension CoreRouter: PaywallRouter { }

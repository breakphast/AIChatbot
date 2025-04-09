//
//  DevSettingsRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol DevSettingsRouter {
    func dismissScreen()
}

extension CoreRouter: DevSettingsRouter { }

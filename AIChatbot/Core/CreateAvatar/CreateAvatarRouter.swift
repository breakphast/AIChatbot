//
//  CreateAvatarRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
protocol CreateAvatarRouter {
    func dismissScreen()
    func showAlert(error: Error)
}

extension CoreRouter: CreateAvatarRouter { }

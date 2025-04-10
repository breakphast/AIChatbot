//
//  RootRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/9/25.
//

import SwiftUI

@MainActor
struct RootRouter: GlobalRouter {
    let router: AnyRouter
    let builder: RootBuilder
}

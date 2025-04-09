//
//  Buildable.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/9/25.
//

import SwiftUI

@MainActor
protocol Builder {
    func build() -> AnyView
}

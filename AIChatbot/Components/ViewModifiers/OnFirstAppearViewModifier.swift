//
//  OnFirstAppearViewModifier.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/14/25.
//

import SwiftUI

struct OnFirstAppearViewModifier: ViewModifier {
    @State private var didAppear = false
    let action: () -> Void
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !didAppear else { return }
                didAppear = true
                action()
            }
    }
}

struct OnFirstTaskViewModifier: ViewModifier {
    @State private var didAppear = false
    let action: () async -> Void
    
    func body(content: Content) -> some View {
        content
            .task {
                guard !didAppear else { return }
                didAppear = true
                await action()
            }
    }
}

extension View {
    func onFirstAppear(action: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearViewModifier(action: action))
    }
    
    func onFirstTask(action: @escaping () async -> Void) -> some View {
        modifier(OnFirstTaskViewModifier(action: action))
    }
}

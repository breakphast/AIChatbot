//
//  NavigationPathOption.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/26/25.
//

import SwiftUI
import Foundation

extension View {
    func navigationDestinationForCoreModule(path: Binding<[NavigationPathOption]>) -> some View {
        self
            .navigationDestination(for: NavigationPathOption.self, destination: { newValue in
                switch newValue {
                case .chat(avatarID: let avatarID, chat: let chat):
                    ChatView(chat: chat, avatarID: avatarID)
                case .category(category: let category, imageName: let imageName):
                    CategoryListView(path: path, category: category, imageName: imageName)
                }
            })
    }
}

enum NavigationPathOption: Hashable {
    case chat(avatarID: String, chat: ChatModel?)
    case category(category: CharacterOption, imageName: String)
}

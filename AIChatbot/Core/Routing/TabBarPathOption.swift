//
//  NavigationPathOption.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/26/25.
//

import SwiftUI
import Foundation

struct NavigationDestinationForTabBarModule: ViewModifier {
    let path: Binding<[TabBarPathOption]>
    @ViewBuilder var chatView: (ChatViewDelegate) -> AnyView
    @ViewBuilder var categoryListView: (CategoryListDelegate) -> AnyView
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(
                for: TabBarPathOption.self,
                destination: { newValue in
                    switch newValue {
                    case .chat(avatarID: let avatarID, chat: let chat):
                        chatView(ChatViewDelegate(chat: chat, avatarID: avatarID))
                    case .category(category: let category, imageName: let imageName):
                        categoryListView(CategoryListDelegate(path: path, category: category, imageName: imageName))
                    }
            })
    }
}

extension View {
    func navigationDestinationForCoreModule(
        path: Binding<[TabBarPathOption]>,
        @ViewBuilder chatView: @escaping (ChatViewDelegate) -> AnyView,
        @ViewBuilder categoryListView: @escaping (CategoryListDelegate) -> AnyView
    ) -> some View {
        modifier(
            NavigationDestinationForTabBarModule(
                path: path,
                chatView: { delegate in
                    chatView(delegate)
                },
                categoryListView: { delegate in
                    categoryListView(delegate)
                }
            )
        )
    }
}

enum TabBarPathOption: Hashable {
    case chat(avatarID: String, chat: ChatModel?)
    case category(category: CharacterOption, imageName: String)
}

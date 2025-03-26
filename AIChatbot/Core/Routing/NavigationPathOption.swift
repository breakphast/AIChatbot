//
//  NavigationPathOption.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/26/25.
//

import SwiftUI
import Foundation

struct NavigationDestinationForCoreModule: ViewModifier {
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[NavigationPathOption]>
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavigationPathOption.self, destination: { newValue in
                switch newValue {
                case .chat(avatarID: let avatarID, chat: let chat):
                    ChatView(chat: chat, avatarID: avatarID)
                case .category(category: let category, imageName: let imageName):
                    CategoryListView(
                        viewModel: CategoryListViewModel(interactor: CoreInteractor(container: container)),
                        path: path,
                        category: category,
                        imageName: imageName
                    )
                }
            })
    }
}

extension View {
    func navigationDestinationForCoreModule(path: Binding<[NavigationPathOption]>) -> some View {
        modifier(NavigationDestinationForCoreModule(path: path))
    }
}

enum NavigationPathOption: Hashable {
    case chat(avatarID: String, chat: ChatModel?)
    case category(category: CharacterOption, imageName: String)
}

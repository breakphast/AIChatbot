//
//  NavigationPathOption.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/26/25.
//

import SwiftUI
import Foundation

struct NavigationDestinationForTabBarModule: ViewModifier {
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[TabBarPathOption]>
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: TabBarPathOption.self, destination: { newValue in
                switch newValue {
                case .chat(avatarID: let avatarID, chat: let chat):
                    ChatView(
                        viewModel: ChatViewModel(interactor: CoreInteractor(container: container)),
                             chat: chat,
                             avatarID: avatarID
                    )
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

struct NavigationDestinationForOnboarding: ViewModifier {
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[OnboardingPathOption]>
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: OnboardingPathOption.self, destination: { newValue in
                switch newValue {
                case .intro:
                    OnboardingIntroView(
                        viewModel: OnboardingIntroViewModel(
                            interactor: CoreInteractor(container: container)
                        ), path: path
                    )
                case .community:
                    OnboardingCommunityView(
                        viewModel: OnboardingCommunityViewModel(
                            interactor: CoreInteractor(container: container)
                        ), path: path
                    )
                case .color:
                    OnboardingColorView(
                        viewModel: OnboardingColorViewModel(
                            interactor: CoreInteractor(container: container), selectedColor: .orange
                        ), path: path
                    )
                case .completed(selectedColor: let color):
                    OnboardingCompletedView(
                        viewModel: OnboardingCompletedViewModel(
                            interactor: CoreInteractor(container: container)
                        ),
                        selectedColor: color
                    )
                }
            })
    }
}

extension View {
    func navigationDestinationForCoreModule(path: Binding<[TabBarPathOption]>) -> some View {
        modifier(NavigationDestinationForTabBarModule(path: path))
    }
    
    func navigationDestinationForOnboarding(path: Binding<[OnboardingPathOption]>) -> some View {
        modifier(NavigationDestinationForOnboarding(path: path))
    }
}

enum TabBarPathOption: Hashable {
    case chat(avatarID: String, chat: ChatModel?)
    case category(category: CharacterOption, imageName: String)
}

enum OnboardingPathOption: Hashable {
    case intro
    case community
    case color
    case completed(selectedColor: Color)
}

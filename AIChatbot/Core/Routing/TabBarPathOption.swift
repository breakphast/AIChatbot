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

struct NavDestinationOnboardingViewModifier: ViewModifier {
    let path: Binding<[OnboardingPathOption]>
    @ViewBuilder var onboardingColorView: (OnboardingColorDelegate) -> AnyView
    @ViewBuilder var onboardingCommunityView: (OnboardingCommunityDelegate) -> AnyView
    @ViewBuilder var onboardingIntroView: (OnboardingIntroDelegate) -> AnyView
    @ViewBuilder var onboardingCompletedView: (OnboardingCompletedDelegate) -> AnyView
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: OnboardingPathOption.self, destination: { newValue in
                switch newValue {
                case .intro:
                    onboardingIntroView(OnboardingIntroDelegate(path: path))
                case .community:
                    onboardingCommunityView(OnboardingCommunityDelegate(path: path))
                case .color:
                    onboardingColorView(OnboardingColorDelegate(path: path))
                case .completed(selectedColor: let color):
                    onboardingCompletedView(OnboardingCompletedDelegate(selectedColor: color))
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
    
    func navigationDestinationForOnboardingModule(
        path: Binding<[OnboardingPathOption]>,
        @ViewBuilder onboardingColorView: @escaping (OnboardingColorDelegate) -> AnyView,
        @ViewBuilder onboardingCommunityView: @escaping (OnboardingCommunityDelegate) -> AnyView,
        @ViewBuilder onboardingIntroView: @escaping (OnboardingIntroDelegate) -> AnyView,
        @ViewBuilder onboardingCompletedView: @escaping (OnboardingCompletedDelegate) -> AnyView
    ) -> some View {
        modifier(
            NavDestinationOnboardingViewModifier(
                path: path,
                onboardingColorView: onboardingColorView,
                onboardingCommunityView: onboardingCommunityView,
                onboardingIntroView: onboardingIntroView,
                onboardingCompletedView: onboardingCompletedView
            )
        )
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

//
//  CoreBuilder.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/28/25.
//

import SwiftUI

@MainActor
struct CoreBuilder {
    let interactor: CoreInteractor
    
    func appView() -> AnyView {
        AppView(
            viewModel: AppViewModel(
                interactor: interactor
            ),
            tabBarView: {
                tabBarView()
            },
            onboardingView: {
                welcomeView()
            }
        )
        .any()
    }
    
    func welcomeView() -> AnyView {
        WelcomeView(
            viewModel: WelcomeViewModel(
                interactor: interactor
            ), 
            createAccountView: { delegate in
                createAccountView(delegate: delegate)
            },
            onboardingColorView: { delegate in
                onboardingColorView(delegate: delegate)
            },
            onboardingCommunityView: { delegate in
                onboardingCommunityView(delegate: delegate)
            },
            onboardingIntroView: { delegate in
                onboardingIntroView(delegate: delegate)
            },
            onboardingCompletedView: { delegate in
                onboardingCompletedView(delegate: delegate)
            }
        )
        .any()
    }
    
    func tabBarView() -> AnyView {
        TabBarView(tabs: [
            TabBarScreen(title: "Explore", systemImage: "eyes", screen: {
                exploreView()
            }),
            TabBarScreen(title: "Chats", systemImage: "bubble.left.and.bubble.right.fill", screen: {
                chatsView()
            }),
            TabBarScreen(title: "Profile", systemImage: "person.fill", screen: {
                profileView()
            })
        ])
        .any()
    }
    
    func createAccountView(delegate: CreateAccountDelegate = CreateAccountDelegate()) -> AnyView {
        CreateAccountView(
            viewModel: CreateAccountViewModel(interactor: interactor),
            delegate: delegate
        )
        .any()
    }
    
    func createAccountView() -> AnyView {
        CreateAccountView(
            viewModel: CreateAccountViewModel(
                interactor: interactor
            )
        )
        .any()
    }
    
    func exploreView() -> AnyView {
        ExploreView(
            viewModel: ExploreViewModel(
                interactor: interactor
            ),
            devSettingsView: {
                devSettingsView()
            },
            createAccountView: {
                createAccountView()
            },
            chatView: { delegate in
                chatView(delegate: delegate)
            },
            categoryListView: { delegate in
                categoryListView(delegate: delegate)
            }
        )
        .any()
    }
    
    func categoryListView(delegate: CategoryListDelegate) -> AnyView {
        CategoryListView(
            viewModel: CategoryListViewModel(interactor: interactor),
            customListCellView: { delegate in
                customListCellView(delegate: delegate)
            },
            delegate: delegate
        )
        .any()
    }
    
    func devSettingsView() -> AnyView {
        DevSettingsView(
            viewModel: DevSettingsViewModel(
                interactor: interactor
            )
        )
        .any()
    }
    
    func paywallView() -> AnyView {
        PaywallView(
            viewModel: PaywallViewModel(
                interactor: interactor
            )
        )
        .any()
    }
    
    func chatView(delegate: ChatViewDelegate = ChatViewDelegate()) -> AnyView {
        ChatView(
            viewModel: ChatViewModel(
                interactor: interactor
            ),
            paywallView: {
                paywallView()
            },
            delegate: delegate
        )
        .any()
    }
    
    func chatsView() -> AnyView {
        ChatsView(
            viewModel: ChatsViewModel(
                interactor: interactor
            ),
            chatRowCell: { delegate in
                chatRowCell(delegate: delegate)
            },
            chatView: { delegate in
                chatView(delegate: delegate)
            },
            categoryListView: { delegate in
                categoryListView(delegate: delegate)
            }
        )
        .any()
    }
    
    func createAvatarView() -> AnyView {
        CreateAvatarView(
            viewModel: CreateAvatarViewModel(
                interactor: interactor
            )
        )
        .any()
    }
    
    func onboardingColorView(delegate: OnboardingColorDelegate) -> AnyView {
        OnboardingColorView(
            viewModel: OnboardingColorViewModel(
                interactor: interactor
            ),
            delegate: delegate
        )
        .any()
    }
    
    func onboardingCommunityView(delegate: OnboardingCommunityDelegate) -> AnyView {
        OnboardingCommunityView(
            viewModel: OnboardingCommunityViewModel(
                interactor: interactor
            ),
            delegate: delegate
        )
        .any()
    }
    
    func onboardingIntroView(delegate: OnboardingIntroDelegate) -> AnyView {
        OnboardingIntroView(
            viewModel: OnboardingIntroViewModel(
                interactor: interactor
            ),
            delegate: delegate
        )
        .any()
    }
    
    func onboardingCompletedView(delegate: OnboardingCompletedDelegate) -> AnyView {
        OnboardingCompletedView(
            viewModel: OnboardingCompletedViewModel(
                interactor: interactor
            ),
            delegate: delegate
        )
        .any()
    }
    
    func settingsView() -> AnyView {
        SettingsView(
            viewModel: SettingsViewModel(
                interactor: interactor
            ),
            createAccountView: {
                createAccountView()
            }
        )
        .any()
    }
    
    func customListCellView(delegate: CustomListCellDelegate) -> AnyView {
        CustomListCellView(delegate: delegate)
            .any()
    }
    
    func profileView() -> AnyView {
        ProfileView(
            viewModel: ProfileViewModel(
                interactor: interactor
            ),
            settingsView: {
                settingsView()
            },
            createAvatarView: {
                createAvatarView()
            },
            customListCellView: { delegate in
                customListCellView(delegate: delegate)
            },
            chatView: { delegate in
                chatView(delegate: delegate)
            },
            categoryListView: { delegate in
                categoryListView(delegate: delegate)
            }
        )
        .any()
    }
    
    // MARK: CELLS
    
    func chatRowCell(delegate: ChatRowCellDelegate = ChatRowCellDelegate()) -> AnyView {
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(
                interactor: interactor
            ),
            delegate: delegate
        )
        .any()
    }
}

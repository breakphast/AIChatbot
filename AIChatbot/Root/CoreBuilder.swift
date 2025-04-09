//
//  CoreBuilder.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/28/25.
//

import SwiftUI
import CustomRouting

typealias RouterView = CustomRouting.RouterView
typealias AlertType = CustomRouting.AlertType
typealias Router = CustomRouting.Router

@MainActor
struct CoreBuilder {
    let interactor: CoreInteractor
    
    func appView() -> some View {
        AppView(
            presenter: AppPresenter(
                interactor: interactor
            ),
            tabBarView: {
                tabBarView()
            },
            onboardingView: {
                welcomeView()
            }
        )
    }
    
    func welcomeView() -> some View {
        RouterView { router in
            WelcomeView(
                presenter: WelcomePresenter(
                    interactor: interactor,
                    router: CoreRouter(router: router, builder: self)
                )
            )
        }
    }
    
    func tabBarView() -> some View {
        TabBarView(tabs: [
            TabBarScreen(title: "Explore", systemImage: "eyes", screen: {
                RouterView { router in
                    exploreView(router: router)
                }
                .any()
            }),
            TabBarScreen(title: "Chats", systemImage: "bubble.left.and.bubble.right.fill", screen: {
                RouterView { router in
                    chatsView(router: router)
                }
                .any()
            }),
            TabBarScreen(title: "Profile", systemImage: "person.fill", screen: {
                RouterView { router in
                    profileView(router: router)
                }
                .any()
            })
        ])
    }
    
    func createAccountView(router: Router, delegate: CreateAccountDelegate = CreateAccountDelegate()) -> some View {
        CreateAccountView(
            presenter: CreateAccountPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func exploreView(router: Router) -> some View {
        ExploreView(
            presenter: ExplorePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
    
    func categoryListView(router: Router, delegate: CategoryListDelegate) -> some View {
        CategoryListView(
            presenter: CategoryListPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func devSettingsView(router: Router) -> some View {
        DevSettingsView(
            presenter: DevSettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
    
    func paywallView(router: Router) -> some View {
        PaywallView(
            presenter: PaywallPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
    
    func chatView(router: Router, delegate: ChatViewDelegate = ChatViewDelegate()) -> some View {
        ChatView(
            presenter: ChatPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func chatsView(router: Router) -> some View {
        ChatsView(
            presenter: ChatsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            chatRowCell: { delegate in
                chatRowCell(delegate: delegate)
            }
        )
    }
    
    func createAvatarView(router: Router) -> some View {
        CreateAvatarView(
            presenter: CreateAvatarPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
    
    func onboardingColorView(router: Router, delegate: OnboardingColorDelegate) -> some View {
        OnboardingColorView(
            presenter: OnboardingColorPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func onboardingCommunityView(router: Router, delegate: OnboardingCommunityDelegate) -> some View {
        OnboardingCommunityView(
            presenter: OnboardingCommunityPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func onboardingIntroView(router: Router, delegate: OnboardingIntroDelegate) -> some View {
        OnboardingIntroView(
            presenter: OnboardingIntroPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func onboardingCompletedView(router: Router, delegate: OnboardingCompletedDelegate) -> some View {
        OnboardingCompletedView(
            presenter: OnboardingCompletedPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func settingsView(router: Router) -> some View {
        SettingsView(
            presenter: SettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
    
    func profileView(router: Router) -> some View {
        ProfileView(
            presenter: ProfilePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
    
    // MARK: CELLS
    
    func chatRowCell(delegate: ChatRowCellDelegate = ChatRowCellDelegate()) -> some View {
        ChatRowCellViewBuilder(
            presenter: ChatRowCellPresenter(
                interactor: interactor
            ),
            delegate: delegate
        )
    }
    
    func aboutView(router: Router, delegate: AboutDelegate) -> some View {
        AboutView(
            presenter: AboutPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}

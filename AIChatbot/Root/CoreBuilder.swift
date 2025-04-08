//
//  CoreBuilder.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/28/25.
//

import SwiftUI
import CustomRouting

typealias RouterView = CustomRouting.RouterView

@MainActor
struct CoreRouter {
    let router: Router
    let builder: CoreBuilder
    
    // MARK: Segues
    
    func showCategoryListView(delegate: CategoryListDelegate) {
        router.showScreen(.push) { _ in
            builder.categoryListView(delegate: delegate)
        }
    }
    
    func showChatView(delegate: ChatViewDelegate) {
        router.showScreen(.push) { _ in
            builder.chatView(delegate: delegate)
        }
    }
    
    func showDevSettingsView() {
        router.showScreen(.sheet) { _ in
            builder.devSettingsView()
        }
    }
    
    func showSettingsView() {
        router.showScreen(.sheet) { _ in
            builder.settingsView()
        }
    }
    
    func showCreateAccountView(delegate: CreateAccountDelegate) {
        router.showScreen(.sheet) { _ in
            builder.createAccountView(delegate: delegate)
                .presentationDetents([.medium])
        }
    }
    
    func showCreateAvatarView() {
        router.showScreen(.fullScreenCover) { _ in
            builder.createAvatarView()
        }
    }
    
    func showOnboardingIntroView(delegate: OnboardingIntroDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingIntroView(router: router, delegate: delegate)
        }
    }
    
    func showOnboardingCommunityView(delegate: OnboardingCommunityDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingCommunityView(router: router, delegate: delegate)
        }
    }
    
    func showOnboardingColorView(delegate: OnboardingColorDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingColorView(router: router, delegate: delegate)
        }
    }
    
    func showOnboardingCompletedView(delegate: OnboardingCompletedDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingCompletedView(router: router, delegate: delegate)
        }
    }
    
    // MARK: Modals
    
    func dismissScreen() {
        router.dismissScreen()
    }
    
    func dismissModal() {
        router.dismissModal()
    }
    
    func showPushNotificationModal(onEnablePressed: @escaping () -> Void, onCancelPressed: @escaping () -> Void) {
        router.showModal(
            backgroundColor: .black.opacity(0.8),
            transition: .move(edge: .bottom),
            destination: {
                CustomModalView(
                    title: "Enable push notifications?",
                    subtitle: "We'll send you reminders and updates!",
                    primaryButtonTitle: "Enable",
                    primaryButtonAction: {
                        onEnablePressed()
                    },
                    secondaryButtonTitle: "Cancel",
                    secondaryButtonAction: {
                        onCancelPressed()
                    }
                )
            }
        )
    }
    
    // MARK: Alerts
    
    func showAlert(_ option: CustomRouting.AlertType, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) {
        router.showAlert(option, title: title, subtitle: subtitle, buttons: buttons)
    }
    
    func showAlert(error: Error) {
        router.showAlert(.alert, title: "Error", subtitle: error.localizedDescription, buttons: nil)
    }
    
    func dismissAlert() {
        router.dismissAlert()
    }
}

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
        RouterView { router in
            WelcomeView(
                viewModel: WelcomeViewModel(
                    interactor: interactor,
                    router: CoreRouter(router: router, builder: self)
                )
            )
        }
        .any()
    }
    
    func tabBarView() -> AnyView {
        TabBarView(tabs: [
            TabBarScreen(title: "Explore", systemImage: "eyes", screen: {
                RouterView { router in
                    exploreView(router: router)
                }
                .any()
            }),
            TabBarScreen(title: "Chats", systemImage: "bubble.left.and.bubble.right.fill", screen: {
                RouterView { router in
                    chatsView()
                }
                .any()
            }),
            TabBarScreen(title: "Profile", systemImage: "person.fill", screen: {
                RouterView { router in
                    profileView()
                }
                .any()
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
    
    func exploreView(router: Router) -> AnyView {
        ExploreView(
            viewModel: ExploreViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
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
    
    func onboardingColorView(router: Router, delegate: OnboardingColorDelegate) -> AnyView {
        OnboardingColorView(
            viewModel: OnboardingColorViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }
    
    func onboardingCommunityView(router: Router, delegate: OnboardingCommunityDelegate) -> AnyView {
        OnboardingCommunityView(
            viewModel: OnboardingCommunityViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }
    
    func onboardingIntroView(router: Router, delegate: OnboardingIntroDelegate) -> AnyView {
        OnboardingIntroView(
            viewModel: OnboardingIntroViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
        .any()
    }
    
    func onboardingCompletedView(router: Router, delegate: OnboardingCompletedDelegate) -> AnyView {
        OnboardingCompletedView(
            viewModel: OnboardingCompletedViewModel(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
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

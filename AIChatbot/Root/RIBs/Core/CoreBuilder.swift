//
//  CoreBuilder.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/28/25.
//

import SwiftUI

@MainActor
struct CoreBuilder: Builder {
    let interactor: CoreInteractor
    
    func build() -> AnyView {
        tabBarView().any()
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
    
    // MARK: Modals
    
    func pushNotificationModal(onEnablePressed: @escaping () -> Void, onCancelPressed: @escaping () -> Void) -> some View {
        let delegate = CustomModalDelegate(
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
        
        return customModalView(delegate: delegate)
    }
    
    func ratingsModal(onYesPressed: @escaping () -> Void, onNoPressed: @escaping () -> Void) -> some View {
        let delegate = CustomModalDelegate(
            title: "Are you enjoying AIChat?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: {
                onYesPressed()
            },
            secondaryButtonTitle: "No",
            secondaryButtonAction: {
                onNoPressed()
            }
        )
        
        return customModalView(delegate: delegate)
    }
    
    func customModalView(delegate: CustomModalDelegate) -> some View {
        CustomModalView(delegate: delegate)
    }
    
    func profileModalView(avatar: AvatarModel, onXMarkPressed: @escaping () -> Void) -> some View {
        let delegate = ProfileModalDelegate(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterOption?.rawValue.capitalized,
            headline: avatar.characterDescription,
            onXMarkPressed: {
                onXMarkPressed()
            }
        )
        
        return profileModalView(delegate: delegate)
    }
    
    func profileModalView(delegate: ProfileModalDelegate) -> some View {
        ProfileModalView(delegate: delegate)
    }
}

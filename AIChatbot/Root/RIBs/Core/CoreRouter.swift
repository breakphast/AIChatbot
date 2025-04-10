//
//  CoreRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI

@MainActor
struct CoreRouter: GlobalRouter {
    let router: Router
    let builder: CoreBuilder
    
    // MARK: Segues
    
    func showCategoryListView(delegate: CategoryListDelegate) {
        router.showScreen(.push) { router in
            builder.categoryListView(router: router, delegate: delegate)
        }
    }
    
    func showChatView(delegate: ChatViewDelegate) {
        router.showScreen(.push) { router in
            builder.chatView(router: router, delegate: delegate)
        }
    }
    
    func showDevSettingsView() {
        router.showScreen(.sheet) { router in
            builder.devSettingsView(router: router)
        }
    }
    
    func showSettingsView() {
        router.showScreen(.sheet) { router in
            builder.settingsView(router: router)
        }
    }
    
    func showAboutView(delegate: AboutDelegate) {
        router.showScreen(.sheet) { router in
            builder.aboutView(router: router, delegate: delegate)
        }
    }
    
    func showPaywallView() {
        router.showScreen(.sheet) { router in
            builder.paywallView(router: router)
        }
    }
    
    func showCreateAccountView(delegate: CreateAccountDelegate, onDismiss: (() -> Void)?) {
        router.showScreen(.sheet, onDismiss: onDismiss) { router in
            builder.createAccountView(router: router, delegate: delegate)
                .presentationDetents([.medium])
        }
    }
    
    func showCreateAvatarView(onDismiss: @escaping () -> Void) {
        router.showScreen(.sheet, onDismiss: onDismiss) { router in
            builder.createAvatarView(router: router)
        }
    }
    
    // MARK: Modals
    
    func showPushNotificationModal(onEnablePressed: @escaping () -> Void, onCancelPressed: @escaping () -> Void) {
        router.showModal(
            transition: .move(edge: .bottom), backgroundColor: .black.opacity(0.8),
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
    
    func showProfileModal(avatar: AvatarModel, onXMarkPressed: @escaping () -> Void) {
        router.showModal(transition: .slide, backgroundColor: .black.opacity(0.6)) {
            ProfileModalView(
                imageName: avatar.profileImageName,
                title: avatar.name,
                subtitle: avatar.characterOption?.rawValue.capitalized,
                headline: avatar.characterDescription) {
                    onXMarkPressed()
                }
                .padding(40)
        }
    }
    
    func showRatingsModal(onYesPressed: @escaping () -> Void, onNoPressed: @escaping () -> Void) {
        router.showModal(transition: .fade, backgroundColor: .black.opacity(0.6)) {
            CustomModalView(
                title: "Are you enjoying AIChat?",
                subtitle: "We'd love to hear your feedback!",
                primaryButtonTitle: "Yes",
                primaryButtonAction: {
                    onYesPressed()
                },
                secondaryButtonTitle: "No",
                secondaryButtonAction: {
                    onNoPressed()
                })
        }
    }
}

//
//  CoreRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI
import CustomRouting

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
    
    func showCreateAccountView(delegate: CreateAccountDelegate, onDisappear: (() -> Void)?) {
        router.showScreen(.sheet) { router in
            builder.createAccountView(router: router, delegate: delegate)
                .presentationDetents([.medium])
                .onDisappear {
                    onDisappear?()
                }
        }
    }
    
    func showCreateAvatarView(onDisappear: @escaping () -> Void) {
        router.showScreen(.fullScreenCover) { router in
            builder.createAvatarView(router: router)
                .onDisappear(perform: onDisappear)
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
    
    func showProfileModal(avatar: AvatarModel, onXMarkPressed: @escaping () -> Void) {
        router.showModal(backgroundColor: .black.opacity(0.6), transition: .slide) {
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
        router.showModal(backgroundColor: .black.opacity(0.6), transition: .fade) {
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

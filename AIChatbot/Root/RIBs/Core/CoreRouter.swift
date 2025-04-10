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
        router.showResizableSheet(sheetDetents: [.medium], selection: nil, showDragIndicator: false, onDismiss: onDismiss) { router in
            builder.createAccountView(router: router, delegate: delegate)
        }
        
//        router.showScreen(.sheet, onDismiss: onDismiss) { router in
//            builder.createAccountView(router: router, delegate: delegate)
//                .presentationDetents([.medium])
//        }
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
                builder.pushNotificationModal(onEnablePressed: onEnablePressed, onCancelPressed: onCancelPressed)
            }
        )
    }
    
    func showProfileModal(avatar: AvatarModel, onXMarkPressed: @escaping () -> Void) {
        router.showModal(transition: .slide, backgroundColor: .black.opacity(0.6)) {
            builder.profileModalView(avatar: avatar, onXMarkPressed: onXMarkPressed)
        }
    }
    
    func showRatingsModal(onYesPressed: @escaping () -> Void, onNoPressed: @escaping () -> Void) {
        router.showModal(transition: .fade, backgroundColor: .black.opacity(0.6)) {
            builder.ratingsModal(onYesPressed: onYesPressed, onNoPressed: onNoPressed)
        }
    }
}

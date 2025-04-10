//
//  OnbRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/9/25.
//

import SwiftUI

@MainActor
struct OnbRouter: GlobalRouter {
    let router: AnyRouter
    let builder: OnbBuilder
    
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
    
    func showOnboardingCategoryView(delegate: OnboardingCategoryDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingCategoryView(router: router, delegate: delegate)
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
}

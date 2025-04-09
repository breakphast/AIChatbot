//
//  OnbRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/9/25.
//

import SwiftUI

@MainActor
struct OnbRouter: GlobalRouter {
    let router: Router
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
    
    func showCreateAccountView(delegate: CreateAccountDelegate, onDisappear: (() -> Void)?) {
        router.showScreen(.sheet) { router in
            builder.createAccountView(router: router, delegate: delegate)
                .presentationDetents([.medium])
                .onDisappear {
                    onDisappear?()
                }
        }
    }
}

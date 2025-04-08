//
//  OnboardingIntroView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/18/25.
//

import SwiftUI

struct OnboardingIntroDelegate {
    
}

struct OnboardingIntroView: View {
    @State var viewModel: OnboardingIntroViewModel
    let delegate: OnboardingIntroDelegate
    
    var body: some View {
        VStack {
            Group {
                Text("Make your own ")
                +
                Text("Avatars ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("and chat with them!\n\nHave ")
                +
                Text("real conversations")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("with AI generated responses.")
            }
            .baselineOffset(6)
            .minimumScaleFactor(0.5)
            .frame(maxHeight: .infinity)
            .padding(24)
            
            ctaButton
        }
        .font(.title3)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingIntroView")
    }
    
    private var ctaButton: some View {
        VStack(spacing: 8) {
            Text("Continue")
                .callToActionButton()
                .padding(24)
                .font(.title3)
                .anyButton {
                    viewModel.onContinueButtonPressed()
                }
        }
    }
}

#Preview("Original") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    RouterView { router in
        builder.onboardingIntroView(router: router, delegate: OnboardingIntroDelegate())
    }
    .previewEnvironment()
}

#Preview("Onboarding Community Test") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(onboardingCommunityTest: true)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.onboardingIntroView(router: router, delegate: OnboardingIntroDelegate())
    }
    .previewEnvironment()
}

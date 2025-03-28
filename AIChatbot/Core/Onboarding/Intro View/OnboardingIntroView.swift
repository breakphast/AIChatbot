//
//  OnboardingIntroView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/18/25.
//

import SwiftUI

struct OnboardingIntroDelegate {
    var path: Binding<[OnboardingPathOption]>
}

struct OnboardingIntroView: View {
    @State var viewModel: OnboardingIntroViewModel
    let delegate: OnboardingIntroDelegate
    
    var body: some View {
        NavigationStack(path: delegate.path) {
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
            .navigationDestinationForOnboarding(path: delegate.path)
        }
    }
    
    private var ctaButton: some View {
        VStack(spacing: 8) {
            Text("Continue")
                .callToActionButton()
                .padding(24)
                .font(.title3)
                .anyButton {
                    viewModel.onContinueButtonPressed(path: delegate.path)
                }
                .accessibilityIdentifier("ContinueButton")
        }
    }
}

#Preview("Original") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    NavigationStack {
        builder.onboardingIntroView(delegate: OnboardingIntroDelegate(path: .constant([])))
    }
    .previewEnvironment()
}

#Preview("Onboarding Community Test") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(onboardingCommunityTest: true)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return NavigationStack {
        builder.onboardingIntroView(delegate: OnboardingIntroDelegate(path: .constant([])))
    }
    .previewEnvironment()
}

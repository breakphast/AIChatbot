//
//  OnboardingIntroView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/18/25.
//

import SwiftUI

struct OnboardingIntroView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingIntroViewModel
    @Binding var path: [OnboardingPathOption]
    
    var body: some View {
        NavigationStack(path: $path) {
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
            .navigationDestinationForOnboarding(path: $path)
        }
    }
    
    private var ctaButton: some View {
        VStack(spacing: 8) {
            Text("Continue")
                .callToActionButton()
                .padding(24)
                .font(.title3)
                .anyButton {
                    viewModel.onContinueButtonPressed(path: $path)
                }
                .accessibilityIdentifier("ContinueButton")
        }
    }
}

#Preview("Original") {
    NavigationStack {
        OnboardingIntroView(
            viewModel: OnboardingIntroViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ),
            path: .constant([])
        )
    }
    .previewEnvironment()
}

#Preview("Onboarding Community Test") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(onboardingCommunityTest: true)))
            
    return NavigationStack {
        OnboardingIntroView(
            viewModel: OnboardingIntroViewModel(
                interactor: CoreInteractor(
                    container: container
                )
            ),
            path: .constant([])
        )
    }
    .previewEnvironment()
}

//
//  OnboardingIntroView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/18/25.
//

import SwiftUI

struct OnboardingIntroView: View {
    @Environment(ABTestManager.self) private var abTestManager
    
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
            NavigationLink {
                if abTestManager.activeTests.onboardingCommunityTest {
                    OnboardingCommunityView()
                } else {
                    OnboardingColorView()
                }
            } label: {
                Text("Continue")
                    .callToActionButton()
            }
            .padding(24)
            .font(.title3)
            .accessibilityIdentifier("ContinueButton")
        }
    }
}

#Preview("Original") {
    NavigationStack {
        OnboardingIntroView()
    }
    .previewEnvironment()
}

#Preview("Onboarding Community Test") {
    NavigationStack {
        OnboardingIntroView()
    }
    .environment(ABTestManager(service: MockABTestService(onboardingCommunityTest: true)))
    .previewEnvironment()
}

//
//  OnboardingCommunityView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/18/25.
//

import SwiftUI

struct OnboardingCommunityDelegate {
    var path: Binding<[OnboardingPathOption]>
}

struct OnboardingCommunityView: View {
    @Environment(CoreBuilder.self) private var builder
    @State var viewModel: OnboardingCommunityViewModel
    let delegate: OnboardingCommunityDelegate
    
    var body: some View {
        NavigationStack(path: delegate.path) {
            VStack {
                VStack(spacing: 40) {
                    ImageLoaderView()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                    Group {
                        Text("Join our community with over ")
                        +
                        Text("1000+ ")
                            .foregroundStyle(.accent)
                            .fontWeight(.semibold)
                        +
                        Text("custom avatars!\nAsk them questions of have a casual conversation!")
                    }
                    .baselineOffset(6)
                    .minimumScaleFactor(0.5)
                    .padding(24)
                }
                .frame(maxHeight: .infinity)
                
                ctaButton
            }
            .padding(24)
            .font(.title3)
            .toolbar(.hidden, for: .navigationBar)
            .screenAppearAnalytics(name: "OnboardingCommunityView")
            .navigationDestinationForOnboarding(path: delegate.path)
        }
    }
    
    private var ctaButton: some View {
        Text("Continue")
            .callToActionButton()
            .font(.title3)
            .anyButton {
                viewModel.onContinueButtonPressed(path: delegate.path)
            }
            .accessibilityIdentifier("OnboardingCommunityContinueButton")
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    NavigationStack {
        builder.onboardingCommunityView(delegate: OnboardingCommunityDelegate(path: .constant([])))
    }
    .previewEnvironment()
}

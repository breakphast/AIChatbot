//
//  OnboardingCommunityView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/18/25.
//

import SwiftUI

struct OnboardingCommunityView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingCommunityViewModel
    @Binding var path: [OnboardingPathOption]
    
    var body: some View {
        NavigationStack(path: $path) {
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
            .navigationDestinationForOnboarding(path: $path)
        }
    }
    
    private var ctaButton: some View {
        Text("Continue")
            .callToActionButton()
            .font(.title3)
            .anyButton {
                viewModel.onContinueButtonPressed(path: $path)
            }
            .accessibilityIdentifier("OnboardingCommunityContinueButton")
    }
}

#Preview {
    NavigationStack {
        OnboardingCommunityView(viewModel: OnboardingCommunityViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), path: .constant([]))
    }
    .previewEnvironment()
}

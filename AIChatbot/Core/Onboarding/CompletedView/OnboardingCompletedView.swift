//
//  OnboardingCompletedView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct OnboardingCompletedDelegate {
    var selectedColor: Color = .orange
    var selectedCategory: CharacterOption = .alien
}

struct OnboardingCompletedView: View {
    @State var presenter: OnboardingCompletedPresenter
    var delegate: OnboardingCompletedDelegate = OnboardingCompletedDelegate()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup complete!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(delegate.selectedColor)
            Text("We've setup your profile and you're ready to start chatting.")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, content: {
            AsyncCallToActionButton(
                isLoading: presenter.isCompletingProfileSetup,
                text: "Finish",
                action: {
                    presenter.onFinishButtonPressed(delegate: delegate)
                }
            )
            .accessibilityIdentifier("FinishButton")
        })
        .padding(24)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingCompletedView")
    }
}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container()))
    
    return RouterView { router in
        builder.onboardingCompletedView(router: router, delegate: OnboardingCompletedDelegate())
    }
    .previewEnvironment()
}

//
//  OnboardingCompletedView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct OnboardingCompletedDelegate {
    var selectedColor: Color = .orange
}

struct OnboardingCompletedView: View {
    @State var viewModel: OnboardingCompletedViewModel
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
                isLoading: viewModel.isCompletingProfileSetup,
                text: "Finish",
                action: {
                    viewModel.onFinishButtonPressed(selectedColor: delegate.selectedColor)
                }
            )
            .accessibilityIdentifier("FinishButton")
        })
        .padding(24)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingCompletedView")
        .showCustomAlert(alert: $viewModel.showAlert)
    }
}

#Preview {
    CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
        .onboardingCompletedView(delegate: OnboardingCompletedDelegate(selectedColor: .mint))
        .previewEnvironment()
}

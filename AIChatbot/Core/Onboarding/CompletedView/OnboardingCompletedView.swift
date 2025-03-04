//
//  OnboardingCompletedView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @Environment(AppState.self) var appState
    @Environment(UserManager.self) var userManager
    
    @State private var isCompletingProfileSetup = false
    var selectedColor: Color = .orange
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup complete!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectedColor)
            Text("We've setup your profile and you're ready to start chatting.")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, content: {
            AsyncCallToActionButton(
                isLoading: isCompletingProfileSetup,
                text: "Finish",
                action: onFinishButtonPressed
            )
        })
        .padding(24)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    func onFinishButtonPressed() {
        isCompletingProfileSetup = true
        Task {
            let hex = selectedColor.asHex()
            try await userManager.markOnboardingCompletedForCurrentUser(profileColorHex: hex)
            isCompletingProfileSetup = false
            appState.updateViewState(showTabBarView: true)
        }
    }
}

#Preview {
    OnboardingCompletedView(selectedColor: .mint)
        .environment(AppState())
        .environment(UserManager(service: MockUserService()))
}

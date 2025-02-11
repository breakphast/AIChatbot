//
//  OnboardingCompletedView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        VStack {
            Text("Onboarding Completed")
                .frame(maxHeight: .infinity)
            
            Button {
                onFinishButtonPressed()
            } label: {
                Text("Finish")
                    .callToActionButton()
            }
        }
        .padding()
    }
    
    func onFinishButtonPressed() {
        appState.updateViewState(showTabBarView: true)
    }
}

#Preview {
    OnboardingCompletedView()
        .environment(AppState())
}

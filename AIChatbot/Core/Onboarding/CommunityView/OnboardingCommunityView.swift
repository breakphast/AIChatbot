//
//  OnboardingCommunityView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/18/25.
//

import SwiftUI

struct OnboardingCommunityView: View {
    var body: some View {
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
    }
    
    private var ctaButton: some View {
        NavigationLink {
            OnboardingColorView()
        } label: {
            Text("Continue")
                .callToActionButton()
        }
        .font(.title3)
    }
}

#Preview {
    NavigationStack {
        OnboardingCommunityView()
    }
    .previewEnvironment()
}

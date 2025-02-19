//
//  OnboardingIntroView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/18/25.
//

import SwiftUI

struct OnboardingIntroView: View {
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
            .frame(maxHeight: .infinity)
            .padding(24)
            
            ctaButton
        }
        .font(.title3)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private var ctaButton: some View  {
        VStack(spacing: 8) {
            NavigationLink {
                OnboardingColorView()
            } label: {
                Text("Continue")
                    .callToActionButton()
            }
            .padding(24)
            .font(.title3)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingIntroView()
    }
}

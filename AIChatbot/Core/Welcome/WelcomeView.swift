//
//  WelcomeView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct WelcomeView: View {
    @State var viewModel: WelcomeViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            ImageLoaderView(urlString: viewModel.imageName)
                .ignoresSafeArea()
            
            titleSection
                .padding(.top, 24)
            
            ctaButtons
                .padding(16)
            
            policyLinks
        }
        .screenAppearAnalytics(name: "WelcomeView")
    }
    
    private var titleSection: some View {
        VStack {
            Text("AI Chat 🤖")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Text("Twitter: @ devsmond")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
    
    private var ctaButtons: some View {
        VStack(spacing: 8) {
            Text("Get Started")
                .callToActionButton()
                .lineLimit(1)
                .accessibilityIdentifier("StartButton")
                .frame(maxWidth: 500)
                .anyButton {
                    viewModel.onGetStartedPressed()
                }
            
            Text("Already have an account? Sign in.")
                .underline()
                .padding(8)
                .tappableBackground()
                .onTapGesture {
                    viewModel.onSignInPressed()
                }
                .lineLimit(1)
                .minimumScaleFactor(0.2)
        }
    }
    
    private var policyLinks: some View {
        HStack(spacing: 8) {
            Link(destination: URL(string: Constants.termsOfServiceURL)!) {
                Text("Terms of Service")
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
            }
            Circle()
                .fill(.accent)
                .frame(width: 4)
            Link(destination: URL(string: Constants.privacyPolicyURL)!) {
                Text("Privacy Policy")
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    
    return builder.welcomeView()
        .previewEnvironment()
}

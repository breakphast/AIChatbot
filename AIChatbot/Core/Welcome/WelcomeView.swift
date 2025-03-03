//
//  WelcomeView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(AppState.self) var appState
    @State var imageName: String = Constants.randomImage
    @State private var showSignInView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ImageLoaderView(urlString: imageName)
                    .ignoresSafeArea()
                
                titleSection
                    .padding(.top)
                
                ctaButtons
                    .padding()
                
                policyLinks
            }
            .sheet(isPresented: $showSignInView) {
                CreateAccountView(
                    title: "Sign in",
                    subtitle: "Connect to an existing account.",
                    onDidSignIn: { isNewUser in
                        handleDidSignIn(isNewUser: isNewUser)
                    }
                )
                .presentationDetents([.medium])
            }
        }
    }
    
    private var titleSection: some View {
        VStack {
            Text("AI Chat 🤖")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Text("Twitter: @ devsmond")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var ctaButtons: some View {
        VStack(spacing: 8) {
            NavigationLink {
                OnboardingIntroView()
            } label: {
                Text("Get Started")
                    .callToActionButton()
            }
            
            Text("Already have an account? Sign in.")
                .underline()
                .padding(8)
                .tappableBackground()
                .onTapGesture {
                    onSignInPressed()
                }
        }
    }
    
    private var policyLinks: some View {
        HStack(spacing: 8) {
            Link(destination: URL(string: Constants.termsOfServiceURL)!) {
                Text("Terms of Service")
            }
            Circle()
                .fill(.accent)
                .frame(width: 4)
            Link(destination: URL(string: Constants.privacyPolicyURL)!) {
                Text("Privacy Policy")
            }
        }
    }
    
    private func onSignInPressed() {
        showSignInView = true
    }
    
    private func handleDidSignIn(isNewUser: Bool) {
        if isNewUser {
            
        } else {
            appState.updateViewState(showTabBarView: true)
        }
    }
}

#Preview {
    WelcomeView()
}

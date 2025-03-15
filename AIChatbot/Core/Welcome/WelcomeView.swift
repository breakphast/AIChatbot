//
//  WelcomeView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(AppState.self) var appState
    @Environment(LogManager.self) var logManager
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
            .screenAppearAnalytics(name: "WelcomeView")
        }
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
            NavigationLink {
                OnboardingIntroView()
            } label: {
                Text("Get Started")
                    .callToActionButton()
                    .lineLimit(1)
            }
            .frame(maxWidth: 500)
            
            Text("Already have an account? Sign in.")
                .underline()
                .padding(8)
                .tappableBackground()
                .onTapGesture {
                    onSignInPressed()
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
    
    enum Event: LoggableEvent {
        case didSignIn(isNewUser: Bool)
        case signInPressed
        
        var eventName: String {
            switch self {
            case .didSignIn:        return "WelcomeView_DidSignIn"
            case .signInPressed:    return "WelcomeView_SignIn_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .didSignIn(isNewUser: let isNewUser):
                return ["isNewUser": isNewUser]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
    
    private func onSignInPressed() {
        logManager.trackEvent(event: Event.signInPressed)
        showSignInView = true
    }
    
    private func handleDidSignIn(isNewUser: Bool) {
        logManager.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))
        if isNewUser {
            
        } else {
            appState.updateViewState(showTabBarView: true)
        }
    }
}

#Preview {
    WelcomeView()
        .previewEnvironment()
}

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
    @Environment(LogManager.self) var logManager
    
    @State private var isCompletingProfileSetup = false
    var selectedColor: Color = .orange
    @State private var showAlert: AnyAppAlert?
    
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
            .accessibilityIdentifier("FinishButton")
        })
        .padding(24)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingCompletedView")
        .showCustomAlert(alert: $showAlert)
    }
    
    enum Event: LoggableEvent {
        case finishStart
        case finishSuccess(hex: String)
        case finishFail(error: Error)
        
        var eventName: String {
            switch self {
            case .finishStart:      return "OnboardingCompletedView_Finish_Start"
            case .finishSuccess:    return "OnboardingCompletedView_Finish_Success"
            case .finishFail:       return "OnboardingCompletedView_Finish_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .finishSuccess(hex: let hex):
                return [
                    "profile_color_hex": hex
                ]
            case .finishFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .finishFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    func onFinishButtonPressed() {
        logManager.trackEvent(event: Event.finishStart)
        isCompletingProfileSetup = true
        
        Task {
            do {
                let hex = selectedColor.asHex()
                try await userManager.markOnboardingCompletedForCurrentUser(profileColorHex: hex)
                isCompletingProfileSetup = false
                appState.updateViewState(showTabBarView: true)
                logManager.trackEvent(event: Event.finishSuccess(hex: hex))
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.finishFail(error: error))
            }
        }
    }
}

#Preview {
    OnboardingCompletedView(selectedColor: .mint)
        .environment(AppState())
        .environment(UserManager(services: MockUserServices()))
}

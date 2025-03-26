//
//  SettingsView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI
import SwiftfulUtilities

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AppState.self) private var appState
    @Environment(LogManager.self) private var logManager
    @Environment(PurchaseManager.self) private var purchaseManager
    @Environment(DependencyContainer.self) private var container
    @State private var isPremium = false
    @State private var isAnonymousUser = false
    @State private var showCreateAccountView = false
    @State private var showAlert: AnyAppAlert?
    @State private var showRatingsModal = false
    
    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchaseSection
                applicationSection
            }
            .lineLimit(1)
            .minimumScaleFactor(0.4)
            .navigationTitle("Settings")
            .showCustomAlert(alert: $showAlert)
            .screenAppearAnalytics(name: "SettingsView")
            .showModal(showModal: $showRatingsModal) {
                ratingsModal
            }
            .sheet(
                isPresented: $showCreateAccountView,
                onDismiss: {
                    setAnonymousAccountStatus()
                },
                content: {
                    CreateAccountView(
                        viewModel: CreateAccountViewModel(interactor: CoreInteractor(container: container))
                    )
                    .presentationDetents([.medium])
                }
            )
            .onAppear {
                setAnonymousAccountStatus()
            }
        }
    }
    
    private var ratingsModal: some View {
        CustomModalView(
            title: "Are you enjoying AIChat?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: {
                onEnjoyingAppYesPressed()
            },
            secondaryButtonTitle: "No",
            secondaryButtonAction: {
                onEnjoyingAppNoPressed()
            })
    }
    
    private var accountSection: some View {
        Section {
            if isAnonymousUser {
                Text("Save & backup account")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onCreateAccountPressed()
                    }
                    .removeListRowFormatting()
            } else {
                Text("Sign Out")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onSignOutPressed()
                    }
                    .removeListRowFormatting()
            }
            
            Text("Delete Account")
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight) {
                    onDeleteAccountPressed()
                }
                .removeListRowFormatting()
        } header: {
            Text("Account")
        }
    }
    
    private var purchaseSection: some View {
        Section {
            HStack {
                Text("Account Status: \(isPremium ? "Premium" : "Free")")
                
                Spacer(minLength: 0)
                
                if !isPremium {
                    Text("Manage")
                        .badgeButton()
                }
            }
            .rowFormatting()
            .anyButton(.highlight) {
                onSignOutPressed()
            }
            .disabled(!isPremium)
            .removeListRowFormatting()
        } header: {
            Text("Purchases")
        }
    }
    
    private var applicationSection: some View {
        Section {
            Text("Rate us on the App Store!")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight, action: {
                    onRatingButtonPressed()
                })
                .removeListRowFormatting()
            
            HStack {
                Text("Version")
                Spacer(minLength: 0)
                Text(Utilities.appVersion ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .removeListRowFormatting()
            
            HStack {
                Text("Build Number")
                Spacer(minLength: 0)
                Text(Utilities.buildNumber ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .removeListRowFormatting()
            
            Text("Contact Us")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight, action: {
                    onContactUsPressed()
                })
                .removeListRowFormatting()
        } header: {
            Text("Application")
        } footer: {
            Text("Created by devsmond.\nLearn more at www.devsmond.com")
                .baselineOffset(6)
        }
    }
    
    enum Event: LoggableEvent {
        case signOutStart
        case signOutSuccess
        case signOutFail(error: Error)
        case deleteAccountStart
        case deleteAccountStartConfirm
        case deleteAccountSuccess
        case deleteAccountFail(error: Error)
        case createAccountPressed
        case contactUsPressed
        case ratingsPressed
        case ratingsYesPressed
        case ratingsNoPressed
        
        var eventName: String {
            switch self {
            case .signOutStart:                 "SettingsView_SignOut_Start"
            case .signOutSuccess:               "SettingsView_SignOut_Success"
            case .signOutFail:                  "SettingsView_SignOut_Fail"
            case .deleteAccountStart:           "SettingsView_DeleteAccount_Start"
            case .deleteAccountStartConfirm:    "SettingsView_DeleteAccount_StartConfirm"
            case .deleteAccountSuccess:         "SettingsView_DeleteAccount_Success"
            case .deleteAccountFail:            "SettingsView_DeleteAccount_Fail"
            case .createAccountPressed:         "SettingsView_CreateAccount_Pressed"
            case .contactUsPressed:             "SettingsView_ContactUs_Pressed"
            case .ratingsPressed:               "SettingsView_Ratings_Pressed"
            case .ratingsYesPressed:            "SettingsView_RatingsYes_Pressed"
            case .ratingsNoPressed:             "SettingsView_RatingsNo_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .signOutFail(error: let error), .deleteAccountFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .signOutFail, .deleteAccountFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    private func onRatingButtonPressed() {
        logManager.trackEvent(event: Event.ratingsPressed)
        showRatingsModal = true
    }
    
    private func onEnjoyingAppYesPressed() {
        logManager.trackEvent(event: Event.ratingsYesPressed)
        showRatingsModal = false
        AppStoreRatingsHelper.requestRatingsReview()
    }
    
    private func onEnjoyingAppNoPressed() {
        logManager.trackEvent(event: Event.ratingsNoPressed)
        showRatingsModal = false
    }
    
    private func onContactUsPressed() {
        logManager.trackEvent(event: Event.contactUsPressed)
        let email = "hello@devsmond.com"
        let emailString = "mailto:\(email)"
        
        guard let url = URL(string: emailString), UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    func onSignOutPressed() {
        logManager.trackEvent(event: Event.signOutStart)
        Task {
            do {
                try authManager.signOut()
                try await purchaseManager.logOut()
                userManager.signOut()
                logManager.trackEvent(event: Event.signOutSuccess)
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.signOutFail(error: error))
            }
        }
    }
    
    private func dismissScreen() async {
        dismiss()
        try? await Task.sleep(for: .seconds(1))
        appState.updateViewState(showTabBarView: false)
    }
    
    func onCreateAccountPressed() {
        showCreateAccountView = true
        logManager.trackEvent(event: Event.createAccountPressed)
    }
    
    func setAnonymousAccountStatus() {
        isAnonymousUser = authManager.auth?.isAnonymous ?? true
    }
    
    func onDeleteAccountPressed() {
        logManager.trackEvent(event: Event.deleteAccountStart)
        showAlert = AnyAppAlert(
            title: "Delete accont?",
            subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our server forever.",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive, action: {
                        onDeleteAccountConfirmed()
                    })
                )
            }
        )
    }
    
    private func onDeleteAccountConfirmed() {
        logManager.trackEvent(event: Event.deleteAccountStartConfirm)

        Task {
            do {
                let uid = try authManager.getAuthID()
                
                try await chatManager.deleteAllChatsForUser(userID: uid)
                try await avatarManager.removeAuthorIDFromAllAvatars(userID: uid)
                try await userManager.deleteCurrentUser()
                try await authManager.deleteAccount()
                try await purchaseManager.logOut()

                logManager.deleteUserProfile()
                logManager.trackEvent(event: Event.deleteAccountSuccess)

                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.deleteAccountFail(error: error))
            }
        }
    }
}

private struct RowFormattingViewModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(colorScheme.backgroundPrimary)
    }
}

fileprivate extension View {
    func rowFormatting() -> some View {
        modifier(RowFormattingViewModifier())
    }
}

#Preview("Not Anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AppState())
        .previewEnvironment()
}

#Preview("Anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AppState())
        .previewEnvironment()
}

#Preview("No auth") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AppState())
        .previewEnvironment()
}

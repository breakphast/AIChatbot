//
//  SettingsInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/27/25.
//

import SwiftUI
import SwiftfulUtilities

@MainActor
@Observable
class SettingsPresenter {
    private let interactor: SettingsInteractor
    private let router: SettingsRouter
    
    private(set) var isPremium = false
    private(set) var isAnonymousUser = false
    
    init(interactor: SettingsInteractor, router: SettingsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    var auth: UserAuthInfo? {
        interactor.auth
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
    
    func onRatingButtonPressed() {
        interactor.trackEvent(event: Event.ratingsPressed)
        
        func onEnjoyingAppYesPressed() {
            interactor.trackEvent(event: Event.ratingsYesPressed)
            router.dismissModal()
            AppStoreRatingsHelper.requestRatingsReview()
        }
        
        func onEnjoyingAppNoPressed() {
            interactor.trackEvent(event: Event.ratingsNoPressed)
            router.dismissModal()
        }
        
        router.showRatingsModal(onYesPressed: {
            onEnjoyingAppYesPressed()
        }, onNoPressed: {
            onEnjoyingAppNoPressed()
        })
    }
    
    func onAboutUsPressed() {
        router.showAboutView(delegate: AboutDelegate())
    }
    
    func onContactUsPressed() {
        interactor.trackEvent(event: Event.contactUsPressed)
        let email = "hello@devsmond.com"
        let emailString = "mailto:\(email)"
        
        guard let url = URL(string: emailString), UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    func onSignOutPressed() {
        interactor.trackEvent(event: Event.signOutStart)
        Task {
            do {
                try await interactor.signOut()
                interactor.trackEvent(event: Event.signOutSuccess)
                
                await dismissScreen()
                
                interactor.updateAppState(showTabBar: false)
            } catch {
                interactor.trackEvent(event: Event.signOutFail(error: error))
                router.showAlert(error: error)
            }
        }
    }
    
    func onCreateAccountPressed() {
        interactor.trackEvent(event: Event.createAccountPressed)
        let delegate = CreateAccountDelegate()
        router.showCreateAccountView(delegate: delegate, onDismiss: {
            self.setAnonymousAccountStatus()
        })
    }
    
    func setAnonymousAccountStatus() {
        isAnonymousUser = interactor.auth?.isAnonymous ?? true
    }
    
    private func dismissScreen() async {
        router.dismissScreen()
        try? await Task.sleep(for: .seconds(1))
    }
    
    func onDeleteAccountPressed() {
        interactor.trackEvent(event: Event.deleteAccountStart)
        router.showAlert(
            .alert,
            title: "Delete accont?",
            subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our server forever.",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive, action: {
                        self.onDeleteAccountConfirmed()
                    })
                )
            }
        )
    }
    
    func onDeleteAccountConfirmed() {
        interactor.trackEvent(event: Event.deleteAccountStartConfirm)

        Task {
            do {
                let uid = try interactor.getAuthID()
                
                try await interactor.deleteAccount(userID: uid)

                interactor.trackEvent(event: Event.deleteAccountSuccess)

                await dismissScreen()
                
                interactor.updateAppState(showTabBar: false)
            } catch {
                interactor.trackEvent(event: Event.deleteAccountFail(error: error))
                router.showAlert(error: error)
            }
        }
    }
}

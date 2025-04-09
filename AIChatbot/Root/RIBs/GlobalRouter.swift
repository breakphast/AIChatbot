//
//  GlobalRouter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/9/25.
//

import SwiftUI

@MainActor
protocol GlobalRouter {
    var router: Router { get }
}

extension GlobalRouter {
    func dismissScreen() {
        router.dismissScreen()
    }
    
    func dismissModal() {
        router.dismissModal()
    }
    
    func showAlert(_ option: AlertType, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) {
        router.showAlert(option, title: title, subtitle: subtitle, buttons: buttons)
    }
    
    func showSimpleAlert(title: String, subtitle: String?) {
        router.showAlert(.alert, title: title, subtitle: subtitle, buttons: nil)
    }
    
    func showAlert(error: Error) {
        router.showAlert(.alert, title: "Error", subtitle: error.localizedDescription, buttons: nil)
    }
    
    func dismissAlert() {
        router.dismissAlert()
    }
}

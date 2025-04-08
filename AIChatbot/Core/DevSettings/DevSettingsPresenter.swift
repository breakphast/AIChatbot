//
//  DevSettingsInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/27/25.
//

import SwiftUI
import SwiftfulUtilities

@MainActor
@Observable
class DevSettingsPresenter {
    private let interactor: DevSettingsInteractor
    private let router: DevSettingsRouter
    
    var createAccountTest: Bool = false
    var onboardingCommunityTest: Bool = false
    var categoryRowTest: CategoryRowTestOption = .default
    var paywallTest: PaywallTestOption = .default
    
    init(interactor: DevSettingsInteractor, router: CoreRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    var authData: [(key: String, value: Any)] {
        interactor.auth?.eventParameters.asAlphabeticalArray ?? []
    }
    
    var userData: [(key: String, value: Any)] {
        interactor.currentUser?.eventParameters.asAlphabeticalArray ?? []
    }
    
    var deviceData: [(key: String, value: Any)] {
        Utilities.eventParameters.asAlphabeticalArray
    }
    
    func loadABTests() {
        createAccountTest = interactor.activeTests.createAccountTest
        onboardingCommunityTest = interactor.activeTests.onboardingCommunityTest
        categoryRowTest = interactor.activeTests.categoryRowTest
        paywallTest = interactor.activeTests.paywallTest
    }
    
    func handleCreateAccountChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &createAccountTest,
            newValue: newValue,
            savedValue: interactor.activeTests.createAccountTest,
            updateAction: { tests in
                tests.update(createAccountTest: newValue)
            }
        )
    }
    
    func handleOnbCommunityTestChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &onboardingCommunityTest,
            newValue: newValue,
            savedValue: interactor.activeTests.onboardingCommunityTest,
            updateAction: { tests in
                tests.update(onboardingCommunityTest: newValue)
            }
        )
    }
    
    func onCategoryRowOptionChanged(oldValue: CategoryRowTestOption, newValue: CategoryRowTestOption) {
        updateTest(
            property: &categoryRowTest,
            newValue: newValue,
            savedValue: interactor.activeTests.categoryRowTest,
            updateAction: { tests in
                tests.update(categoryRowTest: newValue)
            }
        )
    }
    
    func onPaywallOptionChanged(oldValue: PaywallTestOption, newValue: PaywallTestOption) {
        updateTest(
            property: &paywallTest,
            newValue: newValue,
            savedValue: interactor .activeTests.paywallTest,
            updateAction: { tests in
                tests.update(paywallTest: newValue)
            }
        )
    }
    
    private func updateTest<Value: Equatable>(
        property: inout Value,
        newValue: Value,
        savedValue: Value,
        updateAction: (inout ActiveABTests) -> Void
    ) {
        if newValue != savedValue {
            do {
                var tests = interactor.activeTests
                updateAction(&tests)
                try interactor.override(updatedTests: tests)
            } catch {
                property = savedValue
            }
        }
    }
    
    func onBackButtonPressed() {
        router.dismissScreen()
    }
}

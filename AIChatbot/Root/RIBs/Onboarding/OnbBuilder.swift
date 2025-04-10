//
//  OnbBuilder.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/9/25.
//

import SwiftUI

@MainActor
struct OnbBuilder: Builder {
    let interactor: OnbInteractor
    
    func build() -> AnyView {
        welcomeView().any()
    }
    
    func welcomeView() -> some View {
        RouterView { router in
            WelcomeView(
                presenter: WelcomePresenter(
                    interactor: interactor,
                    router: OnbRouter(router: router, builder: self)
                )
            )
        }
    }
    
    func onboardingColorView(router: AnyRouter, delegate: OnboardingColorDelegate) -> some View {
        OnboardingColorView(
            presenter: OnboardingColorPresenter(
                interactor: interactor,
                router: OnbRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func onboardingCommunityView(router: AnyRouter, delegate: OnboardingCommunityDelegate) -> some View {
        OnboardingCommunityView(
            presenter: OnboardingCommunityPresenter(
                interactor: interactor,
                router: OnbRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func onboardingCategoryView(router: AnyRouter, delegate: OnboardingCategoryDelegate) -> some View {
        OnboardingCategoryView(
            presenter: OnboardingCategoryPresenter(
                interactor: interactor,
                router: OnbRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func onboardingIntroView(router: AnyRouter, delegate: OnboardingIntroDelegate) -> some View {
        OnboardingIntroView(
            presenter: OnboardingIntroPresenter(
                interactor: interactor,
                router: OnbRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func onboardingCompletedView(router: AnyRouter, delegate: OnboardingCompletedDelegate) -> some View {
        OnboardingCompletedView(
            presenter: OnboardingCompletedPresenter(
                interactor: interactor,
                router: OnbRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func createAccountView(router: AnyRouter, delegate: CreateAccountDelegate = CreateAccountDelegate()) -> some View {
        CreateAccountView(
            presenter: CreateAccountPresenter(
                interactor: interactor,
                router: OnbRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}

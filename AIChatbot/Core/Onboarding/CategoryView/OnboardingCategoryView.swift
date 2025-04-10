//
//  OnboardingCategoryView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/10/25.
//

import SwiftUI

struct OnboardingCategoryDelegate {
    var selectedColor: Color = .orange
}

struct OnboardingCategoryView: View {
    @State var presenter: OnboardingCategoryPresenter
    let delegate: OnboardingCategoryDelegate
    
    var body: some View {
        VStack {
            
            Text("Which avatar do you want to chat with first?")
                .bold()
                .padding(24)
                .multilineTextAlignment(.center)
            
            Picker("", selection: $presenter.selectedCategory) {
                ForEach(presenter.categories, id: \.self) { category in
                    Text(category.rawValue.capitalized).tag(category)
                }
            }
            .pickerStyle(.wheel)
            
            Text("Continue")
                .callToActionButton()
                .frame(maxHeight: .infinity, alignment: .bottom)
                .anyButton {
                    presenter.onContinueButtonPressed()
                }
        }
        .padding(24)
        .onFirstAppear {
            presenter.selectedColor = delegate.selectedColor
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingCategoryView(router: router, delegate: OnboardingCategoryDelegate())
    }
    .previewEnvironment()
}

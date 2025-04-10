//
//  DevSettingsView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/9/25.
//

import SwiftUI

struct DevSettingsView: View {
    @State var presenter: DevSettingsPresenter
    
    var body: some View {
        List {
            abTestSection
            authSection
            userSection
            deviceSection
        }
        .navigationTitle("Dev settings 🫨")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButtonView
            }
        }
        .screenAppearAnalytics(name: "DevSettings")
        .onFirstAppear {
            presenter.loadABTests()
        }
    }
    
    private var backButtonView: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.black)
            .anyButton {
                presenter.onBackButtonPressed()
            }
    }
    
    private var abTestSection: some View {
        Section {
            Toggle("Create Account Test", isOn: $presenter.createAccountTest)
                .onChange(of: presenter.createAccountTest, presenter.handleCreateAccountChange)
            
            Toggle("Explore Create Avatar Test", isOn: $presenter.createAccountTest)
                .onChange(of: presenter.createAccountTest, presenter.handleCreateAvatarChange)
            
            Toggle("Onb Community Test", isOn: $presenter.onboardingCommunityTest)
                .onChange(of: presenter.onboardingCommunityTest, presenter.handleOnbCommunityTestChange)
            
            Picker("Category Row Test", selection: $presenter.categoryRowTest) {
                ForEach(CategoryRowTestOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .id(option)
                }
            }
            .onChange(of: presenter.categoryRowTest, presenter.onCategoryRowOptionChanged)
            
            Picker("Paywall Test", selection: $presenter.paywallTest) {
                ForEach(PaywallTestOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .id(option)
                }
            }
            .onChange(of: presenter.paywallTest, presenter.onPaywallOptionChanged)
        } header: {
            Text("AB Tests")
        }
        .font(.caption)
    }
    
    private var authSection: some View {
        Section {
            ForEach(presenter.authData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Auth Info")
        }
    }
    
    private var userSection: some View {
        Section {
            ForEach(presenter.userData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("User Info")
        }
    }
    
    private var deviceSection: some View {
        Section {
            ForEach(presenter.deviceData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Device Info")
        }
    }
    
    private func itemRow(item: (key: String, value: Any)) -> some View {
        HStack {
            Text(item.key)
            Spacer(minLength: 4)
            
            if let value = String.convertToString(item.value) {
                Text(value)
            } else {
                Text("Unknown")
            }
        }
        .font(.caption)
        .lineLimit(1)
        .minimumScaleFactor(0.3)
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    
    return RouterView { router in
        builder.devSettingsView(router: router)
    }
    .previewEnvironment()
}

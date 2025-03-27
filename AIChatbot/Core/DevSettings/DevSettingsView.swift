//
//  DevSettingsView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/9/25.
//

import SwiftUI

struct DevSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: DevSettingsViewModel
    
    var body: some View {
        NavigationStack {
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
                viewModel.loadABTests()
            }
        }
    }
    
    private var backButtonView: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.black)
            .anyButton {
                viewModel.onBackButtonPressed {
                    dismiss()
                }
            }
    }
    
    private var abTestSection: some View {
        Section {
            Toggle("Create Account Test", isOn: $viewModel.createAccountTest)
                .onChange(of: viewModel.createAccountTest, viewModel.handleCreateAccountChange)
            
            Toggle("Onb Community Test", isOn: $viewModel.onboardingCommunityTest)
                .onChange(of: viewModel.onboardingCommunityTest, viewModel.handleOnbCommunityTestChange)
            
            Picker("Category Row Test", selection: $viewModel.categoryRowTest) {
                ForEach(CategoryRowTestOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .id(option)
                }
            }
            .onChange(of: viewModel.categoryRowTest, viewModel.onCategoryRowOptionChanged)
            
            Picker("Paywall Test", selection: $viewModel.paywallTest) {
                ForEach(PaywallTestOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .id(option)
                }
            }
            .onChange(of: viewModel.paywallTest, viewModel.onPaywallOptionChanged)
        } header: {
            Text("AB Tests")
        }
        .font(.caption)
    }
    
    private var authSection: some View {
        Section {
            ForEach(viewModel.authData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Auth Info")
        }
    }
    
    private var userSection: some View {
        Section {
            ForEach(viewModel.userData, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("User Info")
        }
    }
    
    private var deviceSection: some View {
        Section {
            ForEach(viewModel.deviceData, id: \.key) { item in
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
    DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvironment()
}

//
//  DevSettingsView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/9/25.
//

import SwiftUI
import SwiftfulUtilities

struct DevSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(ABTestManager.self) private var abTestManager
    @State private var createAccountTest: Bool = false
    @State private var onboardingCommunityTest: Bool = false
    
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
                loadABTests()
            }
        }
    }
    
    private func loadABTests() {
        createAccountTest = abTestManager.activeTests.createAccountTest
        onboardingCommunityTest = abTestManager.activeTests.onboardingCommunityTest
    }
    
    private var backButtonView: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.black)
            .anyButton {
                onBackButtonPressed()
            }
    }
    
    private func onBackButtonPressed() {
        dismiss()
    }
    
    private func handleCreateAccountChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &createAccountTest,
            newValue: newValue,
            savedValue: abTestManager.activeTests.createAccountTest,
            updateAction: { tests in
                tests.update(createAccountTest: newValue)
            }
        )
    }
    
    private func handleOnbCommunityTestChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &onboardingCommunityTest,
            newValue: newValue,
            savedValue: abTestManager.activeTests.onboardingCommunityTest,
            updateAction: { tests in
                tests.update(onboardingCommunityTest: newValue)
            }
        )
    }
    
    private func updateTest(
        property: inout Bool,
        newValue: Bool,
        savedValue: Bool,
        updateAction: (inout ActiveABTests) -> Void
    ) {
        if newValue != savedValue {
            do {
                var tests = abTestManager.activeTests
                updateAction(&tests)
                try abTestManager.override(updatedTests: tests)
            } catch {
                property = savedValue
            }
        }
    }
    
    private var abTestSection: some View {
        Section {
            Toggle("Create Account Test", isOn: $createAccountTest)
                .onChange(of: createAccountTest, handleCreateAccountChange)
            
            Toggle("Onb Community Test", isOn: $onboardingCommunityTest)
                .onChange(of: onboardingCommunityTest, handleOnbCommunityTestChange)
        } header: {
            Text("AB Tests")
        }
        .font(.caption)
    }
    
    private var authSection: some View {
        Section {
            let array = authManager.auth?.eventParameters.asAlphabeticalArray ?? []

            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Auth Info")
        }
    }
    
    private var userSection: some View {
        Section {
            let array = userManager.currentUser?.eventParameters.asAlphabeticalArray ?? []

            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("User Info")
        }
    }
    
    private var deviceSection: some View {
        Section {
            let array = Utilities.eventParameters.asAlphabeticalArray

            ForEach(array, id: \.key) { item in
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
    DevSettingsView()
        .previewEnvironment()
}

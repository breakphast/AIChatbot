//
//  SettingsView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DependencyContainer.self) private var container
    @Environment(CoreBuilder.self) private var builder
    @State var viewModel: SettingsViewModel
    
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
            .showCustomAlert(alert: $viewModel.showAlert)
            .screenAppearAnalytics(name: "SettingsView")
            .showModal(showModal: $viewModel.showRatingsModal) {
                ratingsModal
            }
            .sheet(
                isPresented: $viewModel.showCreateAccountView,
                onDismiss: {
                    viewModel.setAnonymousAccountStatus()
                },
                content: {
                    CreateAccountView(
                        viewModel: CreateAccountViewModel(interactor: CoreInteractor(container: container))
                    )
                    .presentationDetents([.medium])
                }
            )
            .onAppear {
                viewModel.setAnonymousAccountStatus()
            }
        }
    }
    
    func dismissScreen() async {
        dismiss()
        try? await Task.sleep(for: .seconds(1))
    }
    
    private var ratingsModal: some View {
        CustomModalView(
            title: "Are you enjoying AIChat?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: {
                viewModel.onEnjoyingAppYesPressed()
            },
            secondaryButtonTitle: "No",
            secondaryButtonAction: {
                viewModel.onEnjoyingAppNoPressed()
            })
    }
    
    private var accountSection: some View {
        Section {
            if viewModel.isAnonymousUser {
                Text("Save & backup account")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        viewModel.onCreateAccountPressed()
                    }
                    .removeListRowFormatting()
            } else {
                Text("Sign Out")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        viewModel.onSignOutPressed {
                            await dismissScreen()
                        }
                    }
                    .removeListRowFormatting()
            }
            
            Text("Delete Account")
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight) {
                    viewModel.onDeleteAccountPressed {
                        await dismissScreen()
                    }
                }
                .removeListRowFormatting()
        } header: {
            Text("Account")
        }
    }
    
    private var purchaseSection: some View {
        let isPremium = viewModel.isPremium
        
        return Section {
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
                viewModel.onSignOutPressed {
                    await dismissScreen()
                }
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
                    viewModel.onRatingButtonPressed()
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
                    viewModel.onContactUsPressed()
                })
                .removeListRowFormatting()
        } header: {
            Text("Application")
        } footer: {
            Text("Created by devsmond.\nLearn more at www.devsmond.com")
                .baselineOffset(6)
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
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: .mock)))
                       
    return SettingsView(viewModel: SettingsViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("Anonymous") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: .mock)))
    
    return SettingsView(viewModel: SettingsViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("No auth") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))
    
    return SettingsView(viewModel: SettingsViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

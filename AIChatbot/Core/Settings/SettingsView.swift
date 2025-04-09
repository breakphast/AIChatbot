//
//  SettingsView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State var presenter: SettingsPresenter
    
    var body: some View {
        List {
            accountSection
            purchaseSection
            applicationSection
        }
        .lineLimit(1)
        .minimumScaleFactor(0.4)
        .navigationTitle("Settings")
        .screenAppearAnalytics(name: "SettingsView")
        .onAppear {
            presenter.setAnonymousAccountStatus()
        }
    }
    
    private var accountSection: some View {
        Section {
            if presenter.isAnonymousUser {
                Text("Save & backup account")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        presenter.onCreateAccountPressed()
                    }
                    .removeListRowFormatting()
            } else {
                Text("Sign Out")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        presenter.onSignOutPressed()
                    }
                    .removeListRowFormatting()
            }
            
            Text("Delete Account")
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight) {
                    presenter.onDeleteAccountPressed()
                }
                .removeListRowFormatting()
        } header: {
            Text("Account")
        }
    }
    
    private var purchaseSection: some View {
        let isPremium = presenter.isPremium
        
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
                presenter.onSignOutPressed()
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
                    presenter.onRatingButtonPressed()
                })
                .removeListRowFormatting()
            
            Text("About us...")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight, action: {
                    presenter.onAboutUsPressed()
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
                    presenter.onContactUsPressed()
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
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.settingsView(router: router)
    }
    .previewEnvironment()
}

#Preview("Anonymous") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: .mock)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.settingsView(router: router)
    }
    .previewEnvironment()
}

#Preview("No auth") {
    let container = DevPreview.shared.container
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.settingsView(router: router)
    }
    .previewEnvironment()
}

//
//  SettingsView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AppState.self) private var appState
    @State private var isPremium = false
    @State private var isAnonymousUser = false
    @State private var showCreateAccountView = false
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchaseSection
                applicationSection
            }
            .navigationTitle("Settings")
            .showCustomAlert(alert: $showAlert)
            .sheet(
                isPresented: $showCreateAccountView,
                onDismiss: {
                    setAnonymousAccountStatus()
                },
                content: {
                    CreateAccountView()
                        .presentationDetents([.medium])
                }
            )
            .onAppear {
                setAnonymousAccountStatus()
            }
        }
    }
    
    private var accountSection: some View {
        Section {
            if isAnonymousUser {
                Text("Save & backup account")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onCreateAccountPressed()
                    }
                    .removeListRowFormatting()
            } else {
                Text("Sign Out")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onSignOutPressed()
                    }
                    .removeListRowFormatting()
            }
            
            Text("Delete Account")
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight) {
                    onDeleteAccountPressed()
                }
                .removeListRowFormatting()
        } header: {
            Text("Account")
        }
    }
    
    private var purchaseSection: some View {
        Section {
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
                onSignOutPressed()
            }
            .disabled(!isPremium)
            .removeListRowFormatting()
        } header: {
            Text("Purchases")
        }
    }
    
    private var applicationSection: some View {
        Section {
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
                    
                })
                .removeListRowFormatting()
        } header: {
            Text("Application")
        } footer: {
            Text("Created by devsmond.\nLearn more at www.devsmond.com")
                .baselineOffset(6)
        }
    }
    
    func onSignOutPressed() {
        Task {
            do {
                try authManager.signOut()
                userManager.signOut()
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func dismissScreen() async {
        dismiss()
        try? await Task.sleep(for: .seconds(1))
        appState.updateViewState(showTabBarView: false)
    }
    
    func onCreateAccountPressed() {
        showCreateAccountView = true
    }
    
    func setAnonymousAccountStatus() {
        isAnonymousUser = authManager.auth?.isAnonymous ?? true
    }
    
    func onDeleteAccountPressed() {
        showAlert = AnyAppAlert(
            title: "Delete accont?",
            subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our server forever.",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive, action: {
                        onDeleteAccountConfirmed()
                    })
                )
            }
        )
    }
    
    private func onDeleteAccountConfirmed() {
        Task {
            do {
                let uid = try authManager.getAuthID()
                
                async let deleteAuth: () = authManager.deleteAccount()
                async let deleteUser: () = userManager.deleteCurrentUser()
                async let deleteAvatars: () = avatarManager.removeAuthorIDFromAllAvatars(userID: uid)
                async let deleteChats: () = chatManager.deleteAllChatsForUser(userID: uid)
                
                let (_, _, _, _) = await (try deleteAuth, try deleteUser, try deleteAvatars, try deleteChats)
                
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
}

fileprivate extension View {
    func rowFormatting() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(uiColor: .systemBackground))
    }
}

#Preview("Not Anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AppState())
        .previewEnvironment()
}

#Preview("Anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AppState())
        .previewEnvironment()
}

#Preview("No auth") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AppState())
        .previewEnvironment()
}

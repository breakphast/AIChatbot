//
//  ProfileView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @State private var showSettingsView = false
    @State private var showCreateAvatarView = false
    @State private var currentUser: UserModel?
    @State private var myAvatars: [AvatarModel] = []
    @State private var isLoading = true
    
    @State private var path: [NavigationPathOption] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                myInfoSection
                myAvatarSection
            }
            .navigationDestinationForCoreModule(path: $path)
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingsButton
                }
            }
        }
        .sheet(isPresented: $showSettingsView) {
            SettingsView()
        }
        .fullScreenCover(
            isPresented: $showCreateAvatarView,
            onDismiss: {
                Task {
                    await loadData()
                }
            },
            content: {
                CreateAvatarView()
            }
        )
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        self.currentUser = userManager.currentUser
        
        do {
            let uid = try authManager.getAuthID()
            myAvatars = try await avatarManager.getAvatarsForAuthor(userID: uid)
        } catch {
            print("Failed to fetch user avatars.")
        }
        
        isLoading = false
    }
    
    private var settingsButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton {
                onSettingsButtonPressed()
            }
    }
    
    private func onSettingsButtonPressed() {
        showSettingsView = true
    }
    
    private var myInfoSection: some View {
        Section {
            ZStack {
                Circle()
                    .fill(currentUser?.profileColorConverted ?? .accent)
            }
            .frame(width: 100, height: 100)
            .frame(maxWidth: .infinity)
            .removeListRowFormatting()
        }
    }
    
    private var myAvatarSection: some View {
        Section {
            if myAvatars.isEmpty {
                Group {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Click + to create an avatar")
                    }
                }
                .padding(50)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.secondary)
                .removeListRowFormatting()
            } else {
                ForEach(myAvatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: nil
                    )
                    .anyButton(.highlight, action: {
                        onAvatarPressed(avatar: avatar)
                    })
                    .removeListRowFormatting()
                }
                .onDelete { indexSet in
                    onDelete(indexSet: indexSet)
                }
            }
        } header: {
            HStack {
                Text("My Avatars")
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(.accent)
                    .anyButton {
                        onNewAvatarButtonPressed()
                    }
            }
        }
    }
    
    private func onNewAvatarButtonPressed() {
        showCreateAvatarView = true
    }
    
    private func onDelete(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        
        myAvatars.remove(at: index)
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarID: avatar.avatarID))
    }
}

#Preview {
    ProfileView()
        .previewEnvironment()
}

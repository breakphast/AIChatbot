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
    @Environment(LogManager.self) private var logManager
    @State private var showSettingsView = false
    @State private var showCreateAvatarView = false
    @State private var currentUser: UserModel?
    @State private var myAvatars: [AvatarModel] = []
    @State private var isLoading = true
    @State private var showAlert: AnyAppAlert?
    
    @State private var path: [NavigationPathOption] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                myInfoSection
                myAvatarSection
            }
            .navigationDestinationForCoreModule(path: $path)
            .navigationTitle("Profile")
            .showCustomAlert(alert: $showAlert)
            .screenAppearAnalytics(name: "ProfileView")
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
    
    private var settingsButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton {
                onSettingsButtonPressed()
            }
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
                    onDeleteAvatar(indexSet: indexSet)
                }
            }
        } header: {
            HStack {
                Text("My Avatars")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
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
    
    enum Event: LoggableEvent {
        case loadAvatarsStart
        case loadAvatarsSuccess(count: Int)
        case loadAvatarsFail(error: Error)
        case settingsPressed
        case newAvatarPressed
        case avatarPressed(avatar: AvatarModel)
        case deleteAvatarStart(avatar: AvatarModel)
        case deleteAvatarSuccess(avatar: AvatarModel)
        case deleteAvatarFail(error: Error)
        
        var eventName: String {
            switch self {
            case .loadAvatarsStart:         return "ProfileView_LoadAvatars_Start"
            case .loadAvatarsSuccess:       return "ProfileView_LoadAvatars_Success"
            case .loadAvatarsFail:          return "ProfileView_LoadAvatars_Fail"
            case .settingsPressed:          return "ProfileView_SettingsPressed"
            case .newAvatarPressed:         return "ProfileView_NewAvatar_Pressed"
            case .avatarPressed:            return "ProfileView_AvatarPressed"
            case .deleteAvatarStart:        return "ProfileView_DeleteAvatar_Start"
            case .deleteAvatarSuccess:      return "ProfileView_DeleteAvatar_Success"
            case .deleteAvatarFail:         return "ProfileView_DeleteAvatar_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsSuccess(count: let count):
                return [
                    "avatars_count": count
                ]
            case .loadAvatarsFail(error: let error), .deleteAvatarFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar), .deleteAvatarStart(avatar: let avatar), .deleteAvatarSuccess(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarsFail, .deleteAvatarFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    private func onSettingsButtonPressed() {
        logManager.trackEvent(event: Event.settingsPressed)
        showSettingsView = true
    }
    
    private func loadData() async {
        logManager.trackEvent(event: Event.loadAvatarsStart)
        self.currentUser = userManager.currentUser
        
        do {
            let uid = try authManager.getAuthID()
            myAvatars = try await avatarManager.getAvatarsForAuthor(userID: uid)
            logManager.trackEvent(event: Event.loadAvatarsSuccess(count: myAvatars.count))
        } catch {
            print("Failed to fetch user avatars.")
            logManager.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
        
        isLoading = false
    }
    
    private func onNewAvatarButtonPressed() {
        logManager.trackEvent(event: Event.newAvatarPressed)
        showCreateAvatarView = true
    }
    
    private func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatar = myAvatars[index]
        logManager.trackEvent(event: Event.deleteAvatarStart(avatar: avatar))
        
        Task {
            do {
                try await avatarManager.removeAuthorIDFromAvatar(avatarID: avatar.avatarID)
                myAvatars.remove(at: index)
                logManager.trackEvent(event: Event.deleteAvatarSuccess(avatar: avatar))
            } catch {
                showAlert = AnyAppAlert(title: "Unable to delete avatar", subtitle: "Please try again")
                logManager.trackEvent(event: Event.deleteAvatarFail(error: error))
            }
        }
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
        path.append(.chat(avatarID: avatar.avatarID, chat: nil))
    }
}

#Preview {
    ProfileView()
        .previewEnvironment()
}

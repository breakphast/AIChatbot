//
//  ChatsView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct ChatsView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(LogManager.self) private var logManager
    @State private var chats = [ChatModel]()
    @State private var isLoadingChats = true
    @State private var recentAvatars = [AvatarModel]()
    @State private var path: [NavigationPathOption] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !recentAvatars.isEmpty {
                    recentsSection
                }
                chatsSection
            }
            .navigationTitle("Chats")
            .navigationDestinationForCoreModule(path: $path)
            .screenAppearAnalytics(name: "ChatsView")
            .onAppear {
                loadRecentAvatars()
            }
            .task {
                await loadChats()
            }
        }
    }
    
    private var chatsSection: some View {
        Section {
            if isLoadingChats {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .removeListRowFormatting()
            } else {
                if chats.isEmpty {
                    Text("Your chats will appear here!")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(40)
                        .removeListRowFormatting()
                } else {
                    ForEach(chats) { chat in
                        ChatRowCellViewBuilder(
                            chat: chat,
                            getAvatar: {
                                try? await avatarManager.getAvatar(id: chat.avatarID)
                            },
                            getLastChatMessage: {
                                try? await chatManager.getLastChatMesssage(chatID: chat.id)
                            }
                        )
                        .anyButton(.highlight, action: {
                            onChatPressed(chat: chat)
                        })
                        .removeListRowFormatting()
                    }
                }
            }
        } header: {
            Text(chats.isEmpty ? "" : "Chats")
        }
    }
    
    private var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(recentAvatars, id: \.self) { avatar in
                        if let imageName = avatar.profileImageName {
                            VStack(spacing: 8) {
                                ImageLoaderView(urlString: imageName)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(Circle())
                                
                                Text(avatar.name ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .anyButton {
                                onAvatarPressed(avatar: avatar)
                            }
                        }
                    }
                }
                .padding(.top, 12)
            }
            .frame(height: 120)
            .scrollIndicators(.hidden)
            .removeListRowFormatting()
        } header: {
            Text("Recents")
        }
    }
    
    private func loadRecentAvatars() {
        logManager.trackEvent(event: Event.loadAvatarsStart)
        do {
            recentAvatars = try avatarManager.getRecentAvatars()
            logManager.trackEvent(event: Event.loadAvatarsSuccess(avatarCount: recentAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadAvatarsFail(error: error))
            print("Failed to load recents.")
        }
    }
    
    private func loadChats() async {
        logManager.trackEvent(event: Event.loadChatsStart)
        do {
            let uid = try authManager.getAuthID()
            chats = try await chatManager.getAllChats(userID: uid)
                .sortedByKeyPath(keyPath: \.dateModified, ascending: false)
            logManager.trackEvent(event: Event.loadChatsSuccess(chatCount: chats.count))
        } catch {
            logManager.trackEvent(event: Event.loadChatsFail(error: error))
            print("Failed to load chats.")
        }
        
        isLoadingChats = false
    }
    
    private func onChatPressed(chat: ChatModel) {
        path.append(.chat(avatarID: chat.avatarID, chat: chat))
        logManager.trackEvent(event: Event.chatPressed(chat: chat))
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarID: avatar.avatarID, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    enum Event: LoggableEvent {
        case loadChatsStart
        case loadChatsSuccess(chatCount: Int)
        case loadChatsFail(error: Error)
        case loadAvatarsStart
        case loadAvatarsSuccess(avatarCount: Int)
        case loadAvatarsFail(error: Error)
        case chatPressed(chat: ChatModel)
        case avatarPressed(avatar: AvatarModel)
        
        var eventName: String {
            switch self {
            case .loadChatsStart:               return "ChatsView_LoadChats_Start"
            case .loadChatsSuccess:             return "ChatsView_LoadChats_Start"
            case .loadChatsFail:                return "ChatsView_LoadChats_Fail"
            case .loadAvatarsStart:             return "ChatsView_LoadAvatars_Start"
            case .loadAvatarsSuccess:           return "ChatsView_LoadAvatars_Success"
            case .loadAvatarsFail:              return "ChatsView_LoadAvatars_Fail"
            case .chatPressed:                  return "ChatsView_ChatPressed"
            case .avatarPressed:                return "ChatsView_AvatarPressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsSuccess(avatarCount: let avatarCount):
                return [
                    "avatars_count": avatarCount
                ]
            case .loadChatsSuccess(chatCount: let chatCount):
                return [
                    "chats_count": chatCount
                ]
            case .loadChatsFail(error: let error), .loadAvatarsFail(error: let error):
                return error.eventParameters
            case .chatPressed(chat: let chat):
                return chat.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadChatsFail, .loadAvatarsFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

#Preview("Has data") {
    ChatsView()
        .previewEnvironment()
}

#Preview("No data") {
    ChatsView()
        .environment(
            AvatarManager(
                service: MockAvatarService(avatars: []),
                local: MockLocalAvatarPersistence(avatars: [])
            )
        )
        .previewEnvironment()
}

#Preview("Slow loading chats") {
    ChatsView()
        .environment(ChatManager(service: MockChatService(delay: 5)))
        .previewEnvironment()
}

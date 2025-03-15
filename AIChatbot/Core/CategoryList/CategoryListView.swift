//
//  CategoryListView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/26/25.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    @Binding var path: [NavigationPathOption]
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImage
    @State private var avatars = [AvatarModel]()
    @State private var showAlert: AnyAppAlert?
    @State private var isLoading = true
    
    var body: some View {
        List {
            CategoryCellView(
                title: category.pluralized.capitalized,
                imageName: imageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormatting()
            
            if isLoading {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else if avatars.isEmpty {
                Text("No avatars found 😢")
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else {
                ForEach(avatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: avatar.characterDescription
                    )
                    .anyButton(.highlight, action: {
                        onAvatarPressed(avatar: avatar)
                    })
                    .removeListRowFormatting()
                }
            }
        }
        .showCustomAlert(alert: $showAlert)
        .screenAppearAnalytics(name: "CategoryList")
        .ignoresSafeArea()
        .listStyle(.plain)
        .task {
            await loadAvatars()
        }
    }
    
    enum Event: LoggableEvent {
        case loadAvatarsStart
        case loadAvatarsSuccess
        case loadAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel)
        
        var eventName: String {
            switch self {
            case .loadAvatarsStart:     return "CategoryList_LoadAvatar_Start"
            case .loadAvatarsSuccess:   return "CategoryList_LoadAvatar_Success"
            case .loadAvatarsFail:   return "CategoryList_LoadAvatar_Fail"
            case .avatarPressed:        return "CategoryList_Avatar_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsFail(let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarsFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    private func loadAvatars() async {
        logManager.trackEvent(event: Event.loadAvatarsStart)
        do {
            avatars = try await avatarManager.getAvatarsForCategory(category: category)
            logManager.trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            showAlert = AnyAppAlert(error: error)
            logManager.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
        
        isLoading = false
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarID: avatar.avatarID, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
}

#Preview("Has data") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService()))
        .previewEnvironment()
}

#Preview("No data") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService(avatars: [])))
        .previewEnvironment()
}

#Preview("Slow loading") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService(delay: 4)))
        .previewEnvironment()
}

#Preview("Error loading") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService(delay: 4, showError: true)))
        .previewEnvironment()
}

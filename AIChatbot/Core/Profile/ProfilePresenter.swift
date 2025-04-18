//
//  ProfilePresenter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/25/25.
//

import SwiftUI

@MainActor
@Observable
class ProfilePresenter {
    private let interactor: ProfileInteractor
    private let router: ProfileRouter
    
    private(set) var currentUser: UserModel?
    private(set) var myAvatars: [AvatarModel] = []
    private(set) var isLoading = true
    
    init(interactor: ProfileInteractor, router: ProfileRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onSettingsButtonPressed() {
        interactor.trackEvent(event: Event.settingsPressed)
        router.showSettingsView()
    }
    
    func loadData() async {
        interactor.trackEvent(event: Event.loadAvatarsStart)
        currentUser = interactor.currentUser
        
        do {
            let uid = try interactor.getAuthID()
            myAvatars = try await interactor.getAvatarsForAuthor(userID: uid)
            interactor.trackEvent(event: Event.loadAvatarsSuccess(count: myAvatars.count))
        } catch {
            interactor.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
        isLoading = false
    }
    
    func onNewAvatarButtonPressed() {
        interactor.trackEvent(event: Event.newAvatarPressed)
        router.showCreateAvatarView {
            Task {
                await self.loadData()
            }
        }
    }
    
    func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatar = myAvatars[index]
        interactor.trackEvent(event: Event.deleteAvatarStart(avatar: avatar))
        
        Task {
            do {
                try await interactor.removeAuthorIDFromAvatar(avatarID: avatar.avatarID)
                myAvatars.remove(at: index)
                interactor.trackEvent(event: Event.deleteAvatarSuccess(avatar: avatar))
            } catch {
                router.showSimpleAlert(title: "Unable to delete avatar", subtitle: "Please try again")
                interactor.trackEvent(event: Event.deleteAvatarFail(error: error))
            }
        }
    }
    
    func onAvatarPressed(avatar: AvatarModel) {
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
        let delegate = ChatViewDelegate(avatarID: avatar.avatarID)
        router.showChatView(delegate: delegate)
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
}

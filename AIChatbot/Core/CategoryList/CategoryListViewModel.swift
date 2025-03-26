//
//  CategoryListInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/26/25.
//

import SwiftUI

@MainActor
protocol CategoryListInteractor {
    func trackEvent(event: LoggableEvent)
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel]
}

extension CoreInteractor: CategoryListInteractor { }

@MainActor
@Observable
class CategoryListViewModel {
    private let interactor: CategoryListInteractor
    
    private(set) var avatars = [AvatarModel]()
    private(set) var isLoading = true
    
    var showAlert: AnyAppAlert?
    
    init(interactor: CategoryListInteractor) {
        self.interactor = interactor
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
    
    func loadAvatars(category: CharacterOption) async {
        interactor.trackEvent(event: Event.loadAvatarsStart)
        do {
            avatars = try await interactor.getAvatarsForCategory(category: category)
            interactor.trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            showAlert = AnyAppAlert(error: error)
            interactor.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
        
        isLoading = false
    }
    
    func onAvatarPressed(avatar: AvatarModel, path: Binding<[NavigationPathOption]>) {
        path.wrappedValue.append(.chat(avatarID: avatar.avatarID, chat: nil))
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
}

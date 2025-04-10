//
//  ExplorePresenter.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/25/25.
//

import SwiftUI

@MainActor
@Observable
class ExplorePresenter {
    private let interactor: ExploreInteractor
    private let router: ExploreRouter
    
    private(set) var categories = CharacterOption.allCases
    private(set) var featuredAvatars = [AvatarModel]()
    private(set) var popularAvatars = [AvatarModel]()
    private(set) var isLoadingFeatured: Bool = false
    private(set) var isLoadingPopular: Bool = false
    private(set) var showNotificationButton: Bool = false
    
    var categoryRowTestType: CategoryRowTestOption {
        interactor.categoryRowTestType
    }
    
    var createAvatarTest: Bool {
        interactor.createAvatarTest
    }
    
    var showDevSettingsButton: Bool {
        #if DEV || MOCK
        true
        #else
        false
        #endif
    }
    
    init(interactor: ExploreInteractor, router: ExploreRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func handleDeepLink(url: URL) {
        interactor.trackEvent(event: Event.deepLinkStart)
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            interactor.trackEvent(event: Event.deepLinkNoQueryItems)
            return
        }
        
        for queryItem in queryItems {
            if queryItem.name == "category", let value = queryItem.value, let category = CharacterOption(rawValue: value) {
                let imageName = popularAvatars.first(where: { $0.characterOption == category })?.profileImageName ?? Constants.randomImage
                
                let delegate = CategoryListDelegate(category: category, imageName: imageName)
                router.showCategoryListView(delegate: delegate)
                
                interactor.trackEvent(event: Event.deepLinkCategory(category: category))
                return
            }
        }
        
        interactor.trackEvent(event: Event.deepLinkUnknown)
    }
    
    func schedulePushNotifications() {
        interactor.schedulePushNotificationsForTheNextWeek()
    }
    
    func showCreateAccountScreenIfNeeded() {
        Task {
            try? await Task.sleep(for: .seconds(2))
            
            guard
                interactor.auth?.isAnonymous == true &&
                interactor.createAccountTest == true
            else {
                return
            }
            router.showCreateAccountView(delegate: CreateAccountDelegate(), onDismiss: nil)
        }
    }
    
    func handleShowPushNotificationButton() async {
        showNotificationButton = await interactor.canRequestAuthorization()
    }
    
    func onPushNotificationButtonPressed() {
        func onEnablePushNotificationsPressed() {
            Task {
                let isAuthorized = try await interactor.requestAuthorization()
                interactor.trackEvent(event: Event.pushNotifsEnable(isAuthorized: isAuthorized))
                await handleShowPushNotificationButton()
            }
        }
        
        func onCancelPushNotificationsPressed() {
            router.dismissModal()
            interactor.trackEvent(event: Event.pushNotifsCancel)
        }
        
        router.showPushNotificationModal(
            onEnablePressed: {
                onEnablePushNotificationsPressed()
        }, onCancelPressed: {
            onCancelPushNotificationsPressed()
        })
        
        interactor.trackEvent(event: Event.pushNotifsStart)
    }
    
    func onDevSettingsPressed() {
        interactor.trackEvent(event: Event.devSettingsPressed)
        router.showDevSettingsView()
    }
    
    func onCreateAvatarPressed() {
        interactor.trackEvent(event: Event.createAvatarPressed)
        router.showCreateAvatarView(onDismiss: { })
    }
    
    func onTryAgainPressed() {
        isLoadingFeatured = true
        isLoadingPopular = true
        interactor.trackEvent(event: Event.tryAgainPressed)
        
        Task {
            await loadFeaturedAvatars()
        }
        Task {
            await loadPopularAvatars()
        }
    }
    
    func loadFeaturedAvatars() async {
        guard featuredAvatars.isEmpty else { return }
        interactor.trackEvent(event: Event.loadFeaturedAvatarsStart)
        isLoadingFeatured = true
        
        do {
            featuredAvatars = try await interactor.getFeaturedAvatars()
            isLoadingFeatured = false
            interactor.trackEvent(event: Event.loadFeaturedAvatarsSuccess(count: featuredAvatars.count))
        } catch {
            print("Error loading featured avatars: \(error)")
            interactor.trackEvent(event: Event.loadFeaturedAvatarsFail(error: error))
        }
    }
    
    func loadPopularAvatars() async {
        guard popularAvatars.isEmpty else { return }
        interactor.trackEvent(event: Event.loadPopularAvatarsStart)
        isLoadingPopular = true
        
        do {
            popularAvatars = try await interactor.getPopularAvatars()
            isLoadingPopular = false
            interactor.trackEvent(event: Event.loadPopularAvatarsSuccess(count: popularAvatars.count))
        } catch {
            print("Error loading popular avatars: \(error)")
            interactor.trackEvent(event: Event.loadPopularAvatarsFail(error: error))
        }
    }
    
    func onAvatarPressed(avatar: AvatarModel) {
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
        
        let delegate = ChatViewDelegate(chat: nil, avatarID: avatar.avatarID)
        router.showChatView(delegate: delegate)
    }
    
    func onCategoryPressed(category: CharacterOption, imageName: String) {
        interactor.trackEvent(event: Event.categoryPressed(category: category))
        
        let delegate = CategoryListDelegate(category: category, imageName: imageName)
        router.showCategoryListView(delegate: delegate)
    }
    
    enum Event: LoggableEvent {
        case loadFeaturedAvatarsStart
        case loadFeaturedAvatarsSuccess(count: Int)
        case loadFeaturedAvatarsFail(error: Error)
        case loadPopularAvatarsStart
        case loadPopularAvatarsSuccess(count: Int)
        case loadPopularAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel)
        case categoryPressed(category: CharacterOption)
        case tryAgainPressed
        case devSettingsPressed
        case createAvatarPressed
        case pushNotifsStart
        case pushNotifsEnable(isAuthorized: Bool)
        case pushNotifsCancel
        case deepLinkStart
        case deepLinkNoQueryItems
        case deepLinkCategory(category: CharacterOption)
        case deepLinkUnknown
        
        var eventName: String {
            switch self {
            case .loadFeaturedAvatarsStart:            return "Explore_LoadFeatured_Start"
            case .loadFeaturedAvatarsSuccess:          return "Explore_LoadFeatured_Success"
            case .loadFeaturedAvatarsFail:             return "Explore_LoadFeatured_Fail"
            case .loadPopularAvatarsStart:             return "Explore_LoadPopular_Start"
            case .loadPopularAvatarsSuccess:           return "Explore_LoadPopular_Success"
            case .loadPopularAvatarsFail:              return "Explore_LoadPopular_Success"
            case .avatarPressed:                       return "Explore_AvatarPressed"
            case .categoryPressed:                     return "Explore_CategoryPressed"
            case .tryAgainPressed:                     return "Explore_TryAgain_Pressed"
            case .devSettingsPressed:                  return "DevSettings_Pressed"
            case .createAvatarPressed:                 return "CreateAvatar_Pressed"
            case .pushNotifsStart:                     return "Explore_PushNotifs_Start"
            case .pushNotifsEnable:                    return "Explore_PushNotifs_Enable"
            case .pushNotifsCancel:                    return "Explore_PushNotifs_Cancel"
            case .deepLinkStart:                       return "Explore_DeepLink_Start"
            case .deepLinkNoQueryItems:                return "Explore_DeepLink_NoItems"
            case .deepLinkCategory:                    return "Explore_DeepLink_Category"
            case .deepLinkUnknown:                     return "Explore_DeepLink_Unknown"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadFeaturedAvatarsFail(error: let error), .loadPopularAvatarsFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            case .loadFeaturedAvatarsSuccess(count: let count), .loadPopularAvatarsSuccess(count: let count):
                return [
                    "avatars_count": count
                ]
            case .categoryPressed(category: let category), .deepLinkCategory(category: let category):
                return [
                    "category": category.rawValue
                ]
            case .pushNotifsEnable(isAuthorized: let isAuthorized):
                return [
                    "is_authorized": isAuthorized
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadFeaturedAvatarsFail, .loadPopularAvatarsFail, .deepLinkUnknown:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

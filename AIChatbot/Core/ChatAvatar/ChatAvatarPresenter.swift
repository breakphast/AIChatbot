import SwiftUI

@Observable
@MainActor
class ChatAvatarPresenter {
    
    private let interactor: ChatAvatarInteractor
    private let router: ChatAvatarRouter
    
    private(set) var avatars = [AvatarModel]()
    
    init(interactor: ChatAvatarInteractor, router: ChatAvatarRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func loadAvatars(category: CharacterOption) async {
        do {
            avatars = try await interactor.getAvatarsForCategory(category: category)
        } catch {
            
        }
    }
    
    func onAvatarPressed(avatar: AvatarModel) {
        let delegate = ChatViewDelegate(avatarID: avatar.avatarID)
        router.showChatView(delegate: delegate)
    }
    
    func onViewAppear(delegate: ChatAvatarDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
        
        let category = delegate.avatar.characterOption ?? .default
        Task { await self.loadAvatars(category: category) } 
    }
    
    func onViewDisappear(delegate: ChatAvatarDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension ChatAvatarPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: ChatAvatarDelegate)
        case onDisappear(delegate: ChatAvatarDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "ChatAvatarView_Appear"
            case .onDisappear:              return "ChatAvatarView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
//            default:
//                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }

}

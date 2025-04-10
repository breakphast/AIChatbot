import SwiftUI

@Observable
@MainActor
class FeedPresenter {
    
    private let interactor: FeedInteractor
    private let router: FeedRouter
    
    init(interactor: FeedInteractor, router: FeedRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: FeedDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: FeedDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }
}

extension FeedPresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: FeedDelegate)
        case onDisappear(delegate: FeedDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "FeedView_Appear"
            case .onDisappear:              return "FeedView_Disappear"
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

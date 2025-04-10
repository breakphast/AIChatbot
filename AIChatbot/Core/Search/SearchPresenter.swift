import SwiftUI

@Observable
@MainActor
class SearchPresenter {
    
    private let interactor: SearchInteractor
    private let router: SearchRouter
    
    init(interactor: SearchInteractor, router: SearchRouter) {
        self.interactor = interactor
        self.router = router
    }
}

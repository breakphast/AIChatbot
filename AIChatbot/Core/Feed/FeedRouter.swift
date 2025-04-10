import SwiftUI

@MainActor
protocol FeedRouter: GlobalRouter {
    
}

extension CoreRouter: FeedRouter { }

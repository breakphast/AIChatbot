import SwiftUI

@MainActor
protocol FeedInteractor: GlobalInteractor {
    
}

extension CoreInteractor: FeedInteractor { }

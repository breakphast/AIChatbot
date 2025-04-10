import SwiftUI

@MainActor
protocol SearchInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: SearchInteractor { }

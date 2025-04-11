import SwiftUI

@MainActor
protocol ChatAvatarRouter: GlobalRouter {
    func showChatView(delegate: ChatViewDelegate)
}

extension CoreRouter: ChatAvatarRouter { }

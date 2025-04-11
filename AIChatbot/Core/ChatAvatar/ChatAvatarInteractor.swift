import SwiftUI

@MainActor
protocol ChatAvatarInteractor: GlobalInteractor {
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel]
}

extension CoreInteractor: ChatAvatarInteractor { }

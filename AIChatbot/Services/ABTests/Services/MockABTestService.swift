//
//  MockABTestService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/18/25.
//

import SwiftUI

@MainActor
class MockABTestService: ABTestService {
    var activeTests: ActiveABTests
    
    init(
        createAccountTest: Bool? = nil,
        createAvatarTest: Bool? = nil,
        onboardingCommunityTest: Bool? = nil,
        onboardingCategoryTest: Bool? = nil,
        categoryRowTest: CategoryRowTestOption? = nil,
        paywallTest: PaywallTestOption? = nil,
        chatAvatarModalTest: Bool? = nil
    ) {
        self.activeTests = ActiveABTests(
            createAccountTest: createAccountTest ?? false,
            createAvatarTest: createAvatarTest ?? false,
            onboardingCommunityTest: onboardingCommunityTest ?? false,
            onboardingCategoryTest: onboardingCategoryTest ?? false,
            categoryRowTest: categoryRowTest ?? .default,
            paywallTest: paywallTest ?? .default,
            chatAvatarModalTest: chatAvatarModalTest ?? false
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        activeTests = updatedTests
    }
    
    func fetchUpdatedConfig() async throws -> ActiveABTests {
        activeTests
    }
}

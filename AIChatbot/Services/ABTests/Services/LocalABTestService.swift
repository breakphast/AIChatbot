//
//  LocalABTestService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/18/25.
//

import SwiftUI

@MainActor
class LocalABTestService: ABTestService {
    @UserDefault(key: ActiveABTests.CodingKeys.createAccountTest.rawValue, startingValue: .random())
    private var createAccountTest: Bool
    
    @UserDefault(key: ActiveABTests.CodingKeys.createAvatarTest.rawValue, startingValue: .random())
    private var createAvatarTest: Bool
    
    @UserDefault(key: ActiveABTests.CodingKeys.onboardingCategoryTest.rawValue, startingValue: true)
    private var onboardingCategoryTest: Bool
    
    @UserDefault(key: ActiveABTests.CodingKeys.onboardingCommunityTest.rawValue, startingValue: .random())
    private var onboardingCommunityTest: Bool
    
    @UserDefault(key: ActiveABTests.CodingKeys.chatAvatarModalTest.rawValue, startingValue: .random())
    private var chatAvatarModalTest: Bool
    
    @UserDefaultEnum(key: ActiveABTests.CodingKeys.categoryRowTest.rawValue, startingValue: CategoryRowTestOption.allCases.randomElement()!)
    private var categoryRowTest: CategoryRowTestOption
    
    @UserDefaultEnum(key: ActiveABTests.CodingKeys.paywallTest.rawValue, startingValue: PaywallTestOption.allCases.randomElement()!)
    private var paywallTest: PaywallTestOption
    
    var activeTests: ActiveABTests {
        ActiveABTests(
            createAccountTest: createAccountTest,
            createAvatarTest: createAvatarTest,
            onboardingCommunityTest: onboardingCommunityTest,
            onboardingCategoryTest: onboardingCategoryTest,
            categoryRowTest: categoryRowTest,
            paywallTest: paywallTest,
            chatAvatarModalTest: chatAvatarModalTest
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        createAccountTest = updatedTests.createAccountTest
        onboardingCommunityTest = updatedTests.onboardingCommunityTest
        onboardingCategoryTest = updatedTests.onboardingCategoryTest
        categoryRowTest = updatedTests.categoryRowTest
        paywallTest = updatedTests.paywallTest
        chatAvatarModalTest = updatedTests.chatAvatarModalTest
    }
    
    func fetchUpdatedConfig() async throws -> ActiveABTests {
        activeTests
    }
}

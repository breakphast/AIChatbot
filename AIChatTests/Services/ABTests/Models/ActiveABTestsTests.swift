//
//  ActiveABTestsTests.swift
//  AIChatTests
//
//  Created by Desmond Fitch on 3/21/25.
//

import SwiftUI
import Testing
@testable import AIChatbot

struct ActiveABTestsTests {

    @Test("MockABTestService initializes with default values")
    @MainActor
    func testMockABTestServiceDefaultInit() throws {
        let mockService = MockABTestService()
        let tests = mockService.activeTests

        #expect(tests.createAccountTest == false)
        #expect(tests.onboardingCommunityTest == false)
        #expect(tests.categoryRowTest == .default)
        #expect(tests.paywallTest == .default)
    }

    @Test("MockABTestService initializes with custom values")
    @MainActor
    func testMockABTestServiceCustomInit() throws {
        let mockService = MockABTestService(
            createAccountTest: true,
            onboardingCommunityTest: false,
            categoryRowTest: .default,
            paywallTest: .default
        )
        let tests = mockService.activeTests

        #expect(tests.createAccountTest == true)
        #expect(tests.onboardingCommunityTest == false)
        #expect(tests.categoryRowTest == .default)
        #expect(tests.paywallTest == .default)
    }

    @Test("MockABTestService fetchUpdatedConfig returns correct config")
    @MainActor
    func testFetchUpdatedConfig() async throws {
        let expected = ActiveABTests(
            createAccountTest: .random,
            createAvatarTest: .random,
            onboardingCommunityTest: .random,
            onboardingCategoryTest: .random,
            categoryRowTest: .default,
            paywallTest: .default
        )

        let mockService = MockABTestService(
            createAccountTest: expected.createAccountTest,
            onboardingCommunityTest: expected.onboardingCommunityTest,
            categoryRowTest: expected.categoryRowTest,
            paywallTest: expected.paywallTest
        )

        let fetched = try await mockService.fetchUpdatedConfig()

        #expect(fetched.createAccountTest == expected.createAccountTest)
        #expect(fetched.onboardingCommunityTest == expected.onboardingCommunityTest)
        #expect(fetched.categoryRowTest == expected.categoryRowTest)
        #expect(fetched.paywallTest == expected.paywallTest)
    }

    @Test("MockABTestService updates config correctly")
    @MainActor
    func testSaveUpdatedConfig() throws {
        let mockService = MockABTestService()

        let updated = ActiveABTests(
            createAccountTest: .random,
            createAvatarTest: .random,
            onboardingCommunityTest: .random,
            onboardingCategoryTest: .random,
            categoryRowTest: .default,
            paywallTest: .default
        )

        try mockService.saveUpdatedConfig(updatedTests: updated)

        let stored = mockService.activeTests

        #expect(stored.createAccountTest == updated.createAccountTest)
        #expect(stored.onboardingCommunityTest == updated.onboardingCommunityTest)
        #expect(stored.categoryRowTest == updated.categoryRowTest)
        #expect(stored.paywallTest == updated.paywallTest)
    }

    @Test("ActiveABTests encodes and decodes correctly")
    func testCodableRoundTrip() throws {
        let original = ActiveABTests(
            createAccountTest: .random,
            createAvatarTest: .random,
            onboardingCommunityTest: .random,
            onboardingCategoryTest: .random,
            categoryRowTest: .default,
            paywallTest: .default
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ActiveABTests.self, from: data)

        #expect(decoded.createAccountTest == original.createAccountTest)
        #expect(decoded.onboardingCommunityTest == original.onboardingCommunityTest)
        #expect(decoded.categoryRowTest == original.categoryRowTest)
        #expect(decoded.paywallTest == original.paywallTest)
    }

    @Test("ActiveABTests eventParameters returns correct dictionary")
    func testEventParameters() throws {
        let model = ActiveABTests(
            createAccountTest: true,
            createAvatarTest: .random,
            onboardingCommunityTest: false,
            onboardingCategoryTest: .random,
            categoryRowTest: .default,
            paywallTest: .default
        )

        let dict = model.eventParameters

        #expect(dict["test_202503_CreateAccTest"] as? Bool == true)
        #expect(dict["test_202503_OnbCommunityTest"] as? Bool == false)
        #expect(dict["test_202503_categoryRowTest"] as? String == "original")
        #expect(dict["test_202503_paywallTest"] as? String == "storeKit")
    }
}

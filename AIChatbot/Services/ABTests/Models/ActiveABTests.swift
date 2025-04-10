//
//  ActiveABTests.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/18/25.
//

import SwiftUI
import FirebaseRemoteConfig

struct ActiveABTests: Codable {
    private(set) var createAccountTest: Bool
    private(set) var createAvatarTest: Bool
    private(set) var onboardingCommunityTest: Bool
    private(set) var onboardingCategoryTest: Bool
    private(set) var categoryRowTest: CategoryRowTestOption
    private(set) var paywallTest: PaywallTestOption
    
    init(
        createAccountTest: Bool,
        createAvatarTest: Bool,
        onboardingCommunityTest: Bool,
        onboardingCategoryTest: Bool,
        categoryRowTest: CategoryRowTestOption,
        paywallTest: PaywallTestOption
    ) {
        self.createAccountTest = createAccountTest
        self.createAvatarTest = createAvatarTest
        self.onboardingCommunityTest = onboardingCommunityTest
        self.onboardingCategoryTest = onboardingCategoryTest
        self.categoryRowTest = categoryRowTest
        self.paywallTest = paywallTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_202503_CreateAccTest"
        case createAvatarTest = "_202503_CreateAvatarTest"
        case onboardingCommunityTest = "_202503_OnbCommunityTest"
        case onboardingCategoryTest = "_202503_OnbCategoryTest"
        case categoryRowTest = "_202503_categoryRowTest"
        case paywallTest = "_202503_paywallTest"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "test\(CodingKeys.createAvatarTest.rawValue)": createAvatarTest,
            "test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest,
            "test\(CodingKeys.onboardingCategoryTest.rawValue)": onboardingCategoryTest,
            "test\(CodingKeys.categoryRowTest.rawValue)": categoryRowTest.rawValue,
            "test\(CodingKeys.paywallTest.rawValue)": paywallTest.rawValue
        ]
        
        return dict.compactMapValues({ $0 })
    }
    
    mutating func update(createAccountTest newValue: Bool) {
        createAccountTest = newValue
    }
    
    mutating func update(onboardingCommunityTest newValue: Bool) {
        onboardingCommunityTest = newValue
    }
    
    mutating func update(onboardingCategoryTest newValue: Bool) {
        onboardingCategoryTest = newValue
    }
    
    mutating func update(createAvatarTest newValue: Bool) {
        createAvatarTest = newValue
    }
    
    mutating func update(categoryRowTest newValue: CategoryRowTestOption) {
        categoryRowTest = newValue
    }
    
    mutating func update(paywallTest newValue: PaywallTestOption) {
        paywallTest = newValue
    }
}

// MARK: REMOTE CONFIG
extension ActiveABTests {
    init(config: RemoteConfig) {
        let createAccountTest = config.configValue(forKey: ActiveABTests.CodingKeys.createAccountTest.rawValue).boolValue
        self.createAccountTest = createAccountTest
        
        let onboardingCommunityTest = config.configValue(forKey: ActiveABTests.CodingKeys.onboardingCommunityTest.rawValue).boolValue
        self.onboardingCommunityTest = onboardingCommunityTest
        
        let onboardingCategoryTest = config.configValue(forKey: ActiveABTests.CodingKeys.onboardingCategoryTest.rawValue).boolValue
        self.onboardingCategoryTest = onboardingCategoryTest
        
        let createAvatarTest = config.configValue(forKey: ActiveABTests.CodingKeys.createAvatarTest.rawValue).boolValue
        self.createAvatarTest = createAvatarTest
        
        let categoryRowTestStringValue = config.configValue(forKey: ActiveABTests.CodingKeys.categoryRowTest.rawValue).stringValue
        if let option = CategoryRowTestOption(rawValue: categoryRowTestStringValue) {
            self.categoryRowTest = option
        } else {
            self.categoryRowTest = .default
        }
        
        let paywallTestStringValue = config.configValue(forKey: ActiveABTests.CodingKeys.paywallTest.rawValue).stringValue
        if let option = PaywallTestOption(rawValue: paywallTestStringValue) {
            self.paywallTest = option
        } else {
            self.paywallTest = .default
        }
    }
    
    // Converted to a NSObject dictionary to setDefaults within FIrebaseABTestService
    var asNSObjectDictionary: [String: NSObject]? {
        [
            CodingKeys.createAccountTest.rawValue: createAccountTest as NSObject,
            CodingKeys.onboardingCommunityTest.rawValue: onboardingCommunityTest as NSObject,
            CodingKeys.onboardingCategoryTest.rawValue: onboardingCategoryTest as NSObject,
            CodingKeys.categoryRowTest.rawValue: categoryRowTest.rawValue as NSObject,
            CodingKeys.paywallTest.rawValue: paywallTest.rawValue as NSObject
        ]
    }
}

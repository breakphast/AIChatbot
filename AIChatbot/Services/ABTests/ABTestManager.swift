//
//  ABTestManager.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/17/25.
//

import SwiftUI

protocol ABTestService {
    var activeTests: ActiveABTests { get }
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws
}

struct ActiveABTests: Codable {
    private(set) var createAccountTest: Bool
    private(set) var onboardingCommunityTest: Bool
    
    init(createAccountTest: Bool, onboardingCommunityTest: Bool) {
        self.createAccountTest = createAccountTest
        self.onboardingCommunityTest = onboardingCommunityTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_202503_CreateAccTest"
        case onboardingCommunityTest = "_202503_OnbCommunityTest"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest
        ]
        
        return dict.compactMapValues({ $0 })
    }
    
    mutating func update(createAccountTest newValue: Bool) {
        createAccountTest = newValue
    }
    
    mutating func update(onboardingCommunityTest newValue: Bool) {
        onboardingCommunityTest = newValue
    }
}

class MockABTestService: ABTestService {
    var activeTests: ActiveABTests
    
    init(createAccountTest: Bool? = nil, onboardingCommunityTest: Bool? = nil) {
        self.activeTests = ActiveABTests(
            createAccountTest: createAccountTest ?? false,
            onboardingCommunityTest: onboardingCommunityTest ?? false
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        activeTests = updatedTests
    }
}

class LocalABTestService: ABTestService {
    @UserDefault(key: ActiveABTests.CodingKeys.createAccountTest.rawValue, startingValue: .random())
    private var createAccountTest: Bool
    
    @UserDefault(key: ActiveABTests.CodingKeys.onboardingCommunityTest.rawValue, startingValue: .random())
    private var onboardingCommunityTest: Bool
    
    var activeTests: ActiveABTests {
        ActiveABTests(
            createAccountTest: createAccountTest,
            onboardingCommunityTest: onboardingCommunityTest
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        createAccountTest = updatedTests.createAccountTest
        onboardingCommunityTest = updatedTests.onboardingCommunityTest
    }
}

@propertyWrapper
struct GenericWrapper<Value: UserDefaultsCompatible> {
    let key: String
    let startingValue: Value
    
    init(key: String, startingValue: Value) {
        self.key = key
        self.startingValue = startingValue
    }
    
    var wrappedValue: Value {
        get {
            if let savedValue = UserDefaults.standard.value(forKey: key) as? Value {
                return savedValue
            } else {
                UserDefaults.standard.set(startingValue, forKey: key)
                return startingValue
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@MainActor
@Observable
class ABTestManager {
    private let service: ABTestService
    private let logManager: LogManager?
    
    var activeTests: ActiveABTests
    
    init(service: ABTestService, logManager: LogManager? = nil) {
        self.logManager = logManager
        self.service = service
        self.activeTests = service.activeTests
        self.configure()
    }
    
    private func configure() {
        activeTests = service.activeTests
        logManager?.addUserProperties(dict: activeTests.eventParameters, isHighPriority: false)
    }
    
    func override(updatedTests: ActiveABTests) throws {
        try service.saveUpdatedConfig(updatedTests: updatedTests)
        configure()
    }
}

//
//  ABTestManager.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/17/25.
//

import SwiftUI

struct ActiveABTests: Codable {
    let createAccountTest: Bool
    
    init(createAccountTest: Bool) {
        self.createAccountTest = createAccountTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_202503_CreateAccTest"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest
        ]
        
        return dict.compactMapValues({ $0 })
    }
}

protocol ABTestService {
    var activeTests: ActiveABTests { get }
}

struct MockABTestService: ABTestService {
    let activeTests: ActiveABTests
    
    init(createAccountTest: Bool? = nil) {
        self.activeTests = ActiveABTests(createAccountTest: createAccountTest ?? false)
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
        logManager?.addUserProperties(dict: activeTests.eventParameters, isHighPriority: false)
    }
}

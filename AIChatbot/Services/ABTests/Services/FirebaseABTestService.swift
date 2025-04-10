//
//  FirebaseABTestService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/18/25.
//

import SwiftUI
import FirebaseRemoteConfig

@MainActor
class FirebaseABTestService: ABTestService {
    var activeTests: ActiveABTests {
        ActiveABTests(config: RemoteConfig.remoteConfig())
    }
    
    init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        RemoteConfig.remoteConfig().configSettings = settings
        let defaultValues = ActiveABTests(
            createAccountTest: false,
            createAvatarTest: false,
            onboardingCommunityTest: false,
            categoryRowTest: .default,
            paywallTest: .default
        )
        RemoteConfig.remoteConfig().setDefaults(defaultValues.asNSObjectDictionary)
        RemoteConfig.remoteConfig().activate()
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        assertionFailure("Error: Firebase AB Tests are not configurable from the client.")
    }
    
    func fetchUpdatedConfig() async throws -> ActiveABTests {
        let status = try await RemoteConfig.remoteConfig().fetchAndActivate()
        
        switch status {
        case .successFetchedFromRemote, .successUsingPreFetchedData:
            return activeTests
        case .error:
            throw RemoteConfigError.failedToFetch
        default:
            throw RemoteConfigError.failedToFetch
        }
    }
    
    enum RemoteConfigError: LocalizedError {
        case failedToFetch
    }
}

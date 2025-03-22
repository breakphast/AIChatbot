//
//  AuthManagerTests.swift
//  AIChatTests
//
//  Created by Desmond Fitch on 3/21/25.
//

import SwiftUI
import Testing
@testable import AIChatbot

struct AuthManagerTests {

    @Test("AuthManager initializes and attaches auth listener with an authenticated user")
    @MainActor
    func testInitWithAuthListener_authenticatedUser() async throws {
        let mockUser = UserAuthInfo.mock(isAnonymous: true)
        let mockAuth = MockAuthService(user: mockUser)
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])

        let manager = AuthManager(service: mockAuth, logManager: logManager)
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(manager.auth?.uid == mockUser.uid)
        #expect(mockLogService.identifiedUser?.userID == mockUser.uid)
        #expect(!mockLogService.userPropertiesHigh.isEmpty)
        #expect(!mockLogService.userPropertiesLow.isEmpty)

        let eventNames = mockLogService.trackedEvents.map { $0.eventName }
        #expect(eventNames.contains("AuthMan_AuthListener_Start"))
        #expect(eventNames.contains("AuthMan_AuthListener_Success"))
    }

    @Test("AuthManager initializes with no authenticated user and logs only Start event")
    @MainActor
    func testInitWithAuthListener_unauthenticatedUser() async throws {
        let mockAuth = MockAuthService(user: nil)
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])

        let manager = AuthManager(service: mockAuth, logManager: logManager)
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(manager.auth == nil)
        #expect(mockLogService.identifiedUser == nil)
        #expect(mockLogService.userPropertiesHigh.isEmpty)
        #expect(mockLogService.userPropertiesLow.isEmpty)

        let eventNames = mockLogService.trackedEvents.map(\.eventName)
        #expect(eventNames.contains("AuthMan_AuthListener_Start"))
    }

    @Test("AuthManager getAuthID returns ID or throws when nil")
    @MainActor
    func testGetAuthID() throws {
        let mockUser = UserAuthInfo.mock()
        let mockAuth = MockAuthService(user: mockUser)
        let manager = AuthManager(service: mockAuth)

        let id = try manager.getAuthID()
        #expect(id == mockUser.uid)

        let emptyManager = AuthManager(service: MockAuthService(user: nil))
        do {
            _ = try emptyManager.getAuthID()
        } catch is AuthManager.AuthError {
            // pass
        }
    }

    @Test("AuthManager signInAnonymously returns user and sets auth")
    @MainActor
    func testSignInAnonymously() async throws {
        let mockAuth = MockAuthService()
        let manager = AuthManager(service: mockAuth)

        let (user, isNew) = try await manager.signInAnonymously()
        #expect(user.isAnonymous == true)
        #expect(isNew == true)
    }

    @Test("AuthManager signInApple returns user and sets auth")
    @MainActor
    func testSignInApple() async throws {
        let mockAuth = MockAuthService()
        let manager = AuthManager(service: mockAuth)

        let (user, isNew) = try await manager.signInApple()
        #expect(user.isAnonymous == false)
        #expect(isNew == false)
    }

    @Test("AuthManager signOut clears auth and logs events")
    @MainActor
    func testSignOut() throws {
        let mockUser = UserAuthInfo.mock()
        let mockAuth = MockAuthService(user: mockUser)
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        let manager = AuthManager(service: mockAuth, logManager: logManager)

        try manager.signOut()
        #expect(manager.auth == nil)

        let eventNames = mockLogService.trackedEvents.map(\.eventName)
        #expect(eventNames.contains("AuthMan_SignOut_Start"))
        #expect(eventNames.contains("AuthMan_SignOut_Success"))
    }

    @Test("AuthManager deleteAccount clears auth and logs events")
    @MainActor
    func testDeleteAccount() async throws {
        let mockUser = UserAuthInfo.mock()
        let mockAuth = MockAuthService(user: mockUser)
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        let manager = AuthManager(service: mockAuth, logManager: logManager)

        try await manager.deleteAccount()
        #expect(manager.auth == nil)

        let eventNames = mockLogService.trackedEvents.map(\.eventName)
        #expect(eventNames.contains("AuthMan_DeleteAccount_Start"))
        #expect(eventNames.contains("AuthMan_DeleteAccount_Success"))
    }
}

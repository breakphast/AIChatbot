//
//  ProfileViewTests.swift
//  AIChatTests
//
//  Created by Desmond Fitch on 3/24/25.
//

import SwiftUI
import Testing
@testable import AIChatbot

@MainActor
struct ProfileViewTests {

    @Test("loadData does set current user")
    func testLoadDataDoesSetCurrentUser() async {
        let container = DependencyContainer()
        let authManager = AuthManager(service: MockAuthService())
        let mockUser = UserModel.mock
        let userManager = UserManager(services: MockUserServices(user: mockUser))
        let avatarManager = AvatarManager(service: MockAvatarService())
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let viewModel = ProfileViewModel(container: container)
        
        // When
        await viewModel.loadData()
        
        // Then
        #expect(viewModel.currentUser?.id == mockUser.userID)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfileViewModel.Event.loadAvatarsStart.eventName })
    }
    
    @Test("loadData does succeed and user avatars are set")
    func testLoadDataDoesSucceedAndAvatarsAreSet() async {
        let container = DependencyContainer()
        let authUser = UserAuthInfo.mock()
        let authManager = AuthManager(service: MockAuthService(user: authUser))
        let mockUser = UserModel.mock
        let userManager = UserManager(services: MockUserServices(user: mockUser))
        let avatars = AvatarModel.mocks
        let avatarManager = AvatarManager(service: MockAvatarService(avatars: avatars))
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let viewModel = ProfileViewModel(container: container)
        
        // When
        await viewModel.loadData()
        
        // Then
        #expect(viewModel.myAvatars.count == avatars.count)
        #expect(!viewModel.isLoading)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfileViewModel.Event.loadAvatarsSuccess(count: 0).eventName })
    }
    
    @Test("loadData does fail")
    func testLoadDataDoesFail() async {
        let container = DependencyContainer()
        let authManager = AuthManager(service: MockAuthService())
        let mockUser = UserModel.mock
        let userManager = UserManager(services: MockUserServices(user: mockUser))
        let avatars = AvatarModel.mocks
        let avatarManager = AvatarManager(service: MockAvatarService(avatars: avatars))
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let viewModel = ProfileViewModel(container: container)
        
        // When
        await viewModel.loadData()
        
        // Then
        #expect(!viewModel.isLoading)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfileViewModel.Event.loadAvatarsFail(error: URLError(.badURL)).eventName })
    }
    
    @Test("onSettingsButtonPressed")
    func testOnSettingsButtonPressed() async {
        let container = DependencyContainer()
        let authManager = AuthManager(service: MockAuthService())
        let userManager = UserManager(services: MockUserServices())
        let avatarManager = AvatarManager(service: MockAvatarService())
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let viewModel = ProfileViewModel(container: container)
        
        // When
        viewModel.onSettingsButtonPressed()
        
        // Then
        #expect(viewModel.showSettingsView == true)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfileViewModel.Event.settingsPressed.eventName })
    }
    
    @Test("onNewAvatarButtonPressed")
    func testOnNewAvatarButtonPressed() async {
        let container = DependencyContainer()
        let authManager = AuthManager(service: MockAuthService())
        let userManager = UserManager(services: MockUserServices())
        let avatarManager = AvatarManager(service: MockAvatarService())
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let viewModel = ProfileViewModel(container: container)
        
        // When
        viewModel.onNewAvatarButtonPressed()
        
        // Then
        #expect(viewModel.showCreateAvatarView == true)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfileViewModel.Event.newAvatarPressed.eventName })
    }
    
    @Test("onAvatarPressed")
    func testOnAvatarPressed() async {
        let container = DependencyContainer()
        let authManager = AuthManager(service: MockAuthService())
        let userManager = UserManager(services: MockUserServices())
        let avatarManager = AvatarManager(service: MockAvatarService())
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let viewModel = ProfileViewModel(container: container)
        
        // When
        let avatar = AvatarModel.mock
        viewModel.onAvatarPressed(avatar: avatar)
        
        // Then
        #expect(viewModel.path.first == .chat(avatarID: avatar.id, chat: nil))
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfileViewModel.Event.avatarPressed(avatar: avatar).eventName })
    }
    
    @Test("onDeleteAvatar does succeed")
    func testOnDeleteAvatarSuccess() async throws {
        let container = DependencyContainer()
        let authUser = UserAuthInfo.mock()
        let authManager = AuthManager(service: MockAuthService(user: authUser))
        let userManager = UserManager(services: MockUserServices())
        let avatars = AvatarModel.mocks
        let avatarManager = AvatarManager(service: MockAvatarService(avatars: avatars))
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let viewModel = ProfileViewModel(container: container)
        
        // When
        await viewModel.loadData()
        viewModel.onDeleteAvatar(indexSet: IndexSet(integer: 0))
        
        try await Task.sleep(for: .seconds(1))
        
        // Then
        #expect(viewModel.myAvatars.count == (avatars.count - 1))
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfileViewModel.Event.deleteAvatarSuccess(avatar: avatars[0]).eventName })
    }
    
    @Test("onDeleteAvatar does fail")
    func testOnDeleteAvatarFail() async throws {
        let container = DependencyContainer()
        let authUser = UserAuthInfo.mock()
        let authManager = AuthManager(service: MockAuthService(user: authUser))
        let userManager = UserManager(services: MockUserServices())
        let avatars = AvatarModel.mocks
        let avatarManager = AvatarManager(service: MockAvatarService(avatars: avatars, showErrorForRemoveAuthorIDFromAvatar: true))
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let viewModel = ProfileViewModel(container: container)
        
        // When
        await viewModel.loadData()
        viewModel.onDeleteAvatar(indexSet: IndexSet(integer: 0))

        try await Task.sleep(for: .seconds(1))
        
        // Then
        #expect(viewModel.myAvatars.count == (avatars.count))
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfileViewModel.Event.deleteAvatarFail(error: URLError(.unknown)).eventName })
    }
}

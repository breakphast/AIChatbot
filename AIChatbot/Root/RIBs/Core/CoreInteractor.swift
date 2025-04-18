//
//  CoreInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/25/25.
//

import SwiftUI

@MainActor
struct CoreInteractor {
    private let authManager: AuthManager
    private let userManager: UserManager
    private let logManager: LogManager
    private let abTestManager: ABTestManager
    private let purchaseManager: PurchaseManager
    private let appState: AppState
    
    private let aiManager: AIManager
    private let avatarManager: AvatarManager
    private let chatManager: ChatManager
    private let pushManager: PushManager
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
        self.purchaseManager = container.resolve(PurchaseManager.self)!
        self.appState = container.resolve(AppState.self)!
        
        let aiService = container.resolve(AIService.self)!
        self.aiManager = AIManager(service: aiService)
        
        let localAvatarService = container.resolve(LocalAvatarPersistence.self)!
        let remoteAvatarService = container.resolve(RemoteAvatarService.self)!
        self.avatarManager = AvatarManager(service: remoteAvatarService, local: localAvatarService)
        
        let chatService = container.resolve(ChatService.self)!
        self.chatManager = ChatManager(service: chatService)
        
        self.pushManager = PushManager(logManager: logManager)
    }
    
    // MARK: AppState
    
    func updateAppState(showTabBar: Bool) {
        appState.updateViewState(showTabBarView: showTabBar)
    }
    
    // MARK: AuthManager
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    func getAuthID() throws -> String {
        try authManager.getAuthId()
    }
    
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInApple()
    }

    // MARK: UserManager
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    // MARK: AIManager
    func generateImage(input: String) async throws -> UIImage {
        try await aiManager.generateImage(input: input)
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await aiManager.generateText(chats: chats)
    }
    
    // MARK: AvatarManager
    func addRecentAvatar(avatar: AvatarModel) async throws {
        try await avatarManager.addRecentAvatar(avatar: avatar)
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        try avatarManager.getRecentAvatars()
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await avatarManager.getAvatar(id: id)
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await avatarManager.createAvatar(avatar: avatar, image: image)
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await avatarManager.getFeaturedAvatars()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await avatarManager.getPopularAvatars()
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await avatarManager.getAvatarsForCategory(category: category)
    }
    
    func getAvatarsForAuthor(userID: String) async throws -> [AvatarModel] {
        try await avatarManager.getAvatarsForAuthor(userID: userID)
    }
    
    func removeAuthorIDFromAvatar(avatarID: String) async throws {
        try await avatarManager.removeAuthorIDFromAvatar(avatarID: avatarID)
    }
    
    // MARK: ChatManager
    func createNewChat(chat: ChatModel) async throws {
        try await chatManager.createNewChat(chat: chat)
    }
    
    func addChatMessage(chatID: String, message: ChatMessageModel) async throws {
        try await chatManager.addChatMessage(chatID: chatID, message: message)
    }
    
    func markChatMessageAsSeen(chatID: String, messageID: String, userID: String) async throws {
        try await chatManager.markChatMessageAsSeen(chatID: chatID, messageID: messageID, userID: userID)
    }
    
    func getLastChatMessage(chatID: String) async throws -> ChatMessageModel? {
        try await chatManager.getLastChatMessage(chatID: chatID)
    }
    
    func getChat(userID: String, avatarID: String) async throws -> ChatModel? {
        try await chatManager.getChat(userID: userID, avatarID: avatarID)
    }
    
    func getLastChatMesssage(chatID: String) async throws -> ChatMessageModel? {
        try await chatManager.getLastChatMessage(chatID: chatID)
    }
    
    func streamChatMessages(chatID: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        chatManager.streamChatMessages(chatID: chatID)
    }
    
    func getAllChats(userID: String) async throws -> [ChatModel] {
        try await chatManager.getAllChats(userID: userID)
    }
    
    func deleteChat(chatID: String) async throws {
        try await chatManager.deleteChat(chatID: chatID)
    }

    func reportChat(chatID: String, userID: String) async throws {
        try await chatManager.reportChat(chatID: chatID, userID: userID)
    }
    
    // MARK: LogManager
    func identifyUser(userId: String, name: String?, email: String?) {
        logManager.identifyUser(userId: userId, name: name, email: email)
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        logManager.addUserProperties(dict: dict, isHighPriority: isHighPriority)
    }
    
    func deleteUserProfile() {
        logManager.deleteUserProfile()
    }
    
    func trackEvent(eventName: String, parameters: [String: Any]? = nil, type: LogType = .analytic) {
        logManager.trackEvent(eventName: eventName, parameters: parameters, type: type)
    }
    
    func trackEvent(event: AnyLoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func trackEvent(event: LoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func trackScreenEvent(event: LoggableEvent) {
        logManager.trackScreenView(event: event)
    }
    
    // MARK: PushManager
    func requestAuthorization() async throws -> Bool {
        try await pushManager.requestAuthorization()
    }
    
    func canRequestAuthorization() async -> Bool {
        await pushManager.canRequestAuthorization()
    }
    
    func schedulePushNotificationsForTheNextWeek() {
        pushManager.schedulePushNotificationsForTheNextWeek()
    }
    
    // MARK: ABTestManager
    func override(updatedTests: ActiveABTests) throws {
        try abTestManager.override(updatedTests: updatedTests)
    }
    
    var activeTests: ActiveABTests {
        abTestManager.activeTests
    }
    
    // MARK: PurchaseManager
    func getProducts(productIDs: [String]) async throws -> [AnyProduct] {
        try await purchaseManager.getProducts(productIds: productIDs)
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        try await purchaseManager.restorePurchase()
    }
    
    func purchaseProduct(productID: String) async throws -> [PurchasedEntitlement] {
        try await purchaseManager.purchaseProduct(productId: productID)
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        try await purchaseManager.updateProfileAttributes(attributes: attributes)
    }
    
    var entitlements: [PurchasedEntitlement] {
        purchaseManager.entitlements
    }
    
    var isPremium: Bool {
        return purchaseManager.entitlements.hasActiveEntitlement
    }
    
    // MARK: ExploreView
    var categoryRowTestType: CategoryRowTestOption {
        abTestManager.activeTests.categoryRowTest
    }
    
    func schedulePushNotifications() {
        pushManager.schedulePushNotificationsForTheNextWeek()
    }
    
    var createAccountTest: Bool {
        abTestManager.activeTests.createAccountTest
    }
    
    var createAvatarTest: Bool {
        abTestManager.activeTests.createAvatarTest
    }
    
    var chatAvatarModalTest: Bool {
        abTestManager.activeTests.chatAvatarModalTest
    }
        
    // MARK: SHARED
    func signOut() async throws {
        try authManager.signOut()
        try await purchaseManager.logOut()
        userManager.signOut()
    }
    
    func login(user: UserAuthInfo, isNewUser: Bool) async throws {
        try await userManager.login(auth: user, isNewUser: isNewUser)
        try await purchaseManager.logIn(
            userId: user.uid,
            userAttributes: PurchaseProfileAttributes(
                email: user.email,
                mixpanelDistinctId: Constants.mixpanelDistinctID,
                firebaseAppInstanceId: Constants.firebaseAnalyticsAppInstanceID
            )
        )
    }
    
    func deleteAccount(userID: String) async throws {
        try await chatManager.deleteAllChatsForUser(userID: userID)
        try await avatarManager.removeAuthorIDFromAllAvatars(userID: userID)
        try await userManager.deleteCurrentUser()
        try await authManager.deleteAccount()
        try await purchaseManager.logOut()
        logManager.deleteUserProfile()
    }
}

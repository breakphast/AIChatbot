//
//  UserManager.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/3/25.
//

import SwiftUI
import FirebaseFirestore
import SwiftfulFirestore

@MainActor
@Observable
class UserManager {
    private let remote: RemoteUserService
    private let local: LocalUserPersistence
    private let logManager: LogManager?
    
    private(set) var currentUser: UserModel?
    private var currentUserListener: ListenerRegistration?
    
    init(services: UserServices, logManager: LogManager? = nil) {
        self.remote = services.remote
        self.local = services.local
        self.currentUser = local.getCurrentUser()
        self.logManager = logManager
    }
    
    enum Event: LoggableEvent {
        case loginStart(user: UserModel?)
        case loginSuccess(user: UserModel?)
        case remoteListenerStart
        case remoteListenerSuccess(user: UserModel?)
        case remoteListenerFail(error: Error)
        case saveLocalStart(user: UserModel?)
        case saveLocalSuccess(user: UserModel?)
        case saveLocalFail(error: Error)
        case signOut
        case deleteAccountStart
        case deleteAccountSuccess
        
        var eventName: String {
            switch self {
            case .loginStart:                   return "UserManager_LogIn_Start"
            case .loginSuccess:                 return "UserManager_LogIn_Success"
            case .remoteListenerStart:          return "UserManager_RemoteListener_Start"
            case .remoteListenerSuccess:        return "UserManager_RemoteListener_Success"
            case .remoteListenerFail:           return "UserManager_RemoteListener_Fail"
            case .saveLocalStart:               return "UserManager_SaveLocal_Start"
            case .saveLocalSuccess:             return "UserManager_SaveLocal_Success"
            case .saveLocalFail:                return "UserManager_SaveLocal_Fail"
            case .signOut:                      return "UserManager_SignOut"
            case .deleteAccountStart:           return "UserManager_DeleteAccount_Start"
            case .deleteAccountSuccess:         return "UserManager_DeleteAccount_Success"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loginStart(user: let user), .loginSuccess(user: let user), .remoteListenerSuccess(user: let user), .saveLocalSuccess(user: let user):
                return user?.eventParameters
            case .saveLocalFail(error: let error), .remoteListenerFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .saveLocalFail, .remoteListenerFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    func login(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        logManager?.trackEvent(event: Event.loginStart(user: user))
        
        try await remote.saveUser(user: user)
        logManager?.trackEvent(event: Event.loginSuccess(user: user))
        
        addCurrentUserListener(userID: auth.uid)
    }
    
    private func addCurrentUserListener(userID: String) {
        logManager?.trackEvent(event: Event.remoteListenerStart)
        Task {
            do {
                for try await value in remote.streamUser(userID: userID) {
                    self.currentUser = value
                    self.saveCurrentUserLocally()
                    logManager?.trackEvent(event: Event.remoteListenerSuccess(user: value))
                    logManager?.addUserProperties(dict: value.eventParameters, isHighPriority: true)
                }
            } catch {
                logManager?.trackEvent(event: Event.remoteListenerFail(error: error))
            }
        }
    }
    
    private func saveCurrentUserLocally() {
        logManager?.trackEvent(event: Event.saveLocalStart(user: currentUser))
        Task {
            do {
                try local.saveCurrentUser(user: currentUser)
                logManager?.trackEvent(event: Event.saveLocalSuccess(user: currentUser))
            } catch {
                logManager?.trackEvent(event: Event.saveLocalFail(error: error))
            }
        }
    }
    
    func markOnboardingCompletedForCurrentUser(profileColorHex: String, category: String) async throws {
        let uid = try currentUserID()
        try await remote.markOnboardingCompleted(userID: uid, profileColorHex: profileColorHex, category: category)
    }
    
    func signOut() {
        logManager?.trackEvent(event: Event.signOut)
        currentUserListener?.remove()
        currentUserListener = nil
        currentUser = nil
    }
    
    func deleteCurrentUser() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
        
        let uid = try currentUserID()
        try await remote.deleteUser(userID: uid)
        logManager?.trackEvent(event: Event.deleteAccountSuccess)
    }
    
    private func currentUserID() throws -> String {
        guard let uid = currentUser?.userID else {
            throw UserManagerError.noUserID
        }
        
        return uid
    }
    
    enum UserManagerError: LocalizedError {
        case noUserID
    }
}

@MainActor
protocol RemoteUserService: Sendable {
    func saveUser(user: UserModel) async throws
    func markOnboardingCompleted(userID: String, profileColorHex: String, category: String?) async throws
    func streamUser(userID: String) -> AsyncThrowingStream<UserModel, Error>
    func deleteUser(userID: String) async throws
}

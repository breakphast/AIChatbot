//
//  PurchaseManager.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/19/25.
//

import SwiftUI

@MainActor
@Observable
class PurchaseManager {
    private let service: PurchaseService
    private let logManager: LogManager?
    
    /// User's purchased entitlements, sorted by most recent
    private(set) var entitlements: [PurchasedEntitlement] = []
    private(set) var listener: Task<Void, Error>?
    
    init(service: PurchaseService, logManager: LogManager? = nil) {
        self.service = service
        self.logManager = logManager
        self.configure()
    }
    
    private func configure() {
        Task {
            if let entitlements = try? await service.getUserEntitlements() {
                updateActiveEntitlements(entitlements: entitlements)
            }
        }
        
        listener?.cancel()
        listener = Task {
            await service.listenForTransactions { entitlements in
                await updateActiveEntitlements(entitlements: entitlements)
            }
        }
    }
    
    private func updateActiveEntitlements(entitlements: [PurchasedEntitlement]) {
        self.entitlements = entitlements.sortedByKeyPath(keyPath: \.expirationDateCalc, ascending: false)
        
        logManager?.addUserProperties(dict: entitlements.eventParameters, isHighPriority: false)
    }
    
    func getProducts(productIDs: [String]) async throws -> [AnyProduct] {
        logManager?.trackEvent(event: Event.getProductsStart)
        do {
            let products = try await service.getProducts(productIDs: productIDs)
            logManager?.trackEvent(event: Event.getProductsSuccess(products: products))
            return products
        } catch {
            logManager?.trackEvent(event: Event.purchaseFail(error: error))
            throw error
        }
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        logManager?.trackEvent(event: Event.restorePurchaseStart)
        do {
            let entitlements = try await service.restorePurchase()
            logManager?.trackEvent(event: Event.restorePurchaseSuccess(entitlements: entitlements))
            updateActiveEntitlements(entitlements: entitlements)
            return entitlements
        } catch {
            logManager?.trackEvent(event: Event.purchaseFail(error: error))
            throw error
        }
    }
    
    func purchaseProduct(productID: String) async throws -> [PurchasedEntitlement] {
        logManager?.trackEvent(event: Event.purchaseStart)
        do {
            let entitlements = try await service.purchaseProduct(productID: productID)
            logManager?.trackEvent(event: Event.purchaseSuccess(entitlements: entitlements))
            updateActiveEntitlements(entitlements: entitlements)
            return entitlements
        } catch {
            logManager?.trackEvent(event: Event.purchaseFail(error: error))
            throw error
        }
    }
    
    @discardableResult
    func login(userID: String, attributes: PurchaseProfileAttributes? = nil) async throws -> [PurchasedEntitlement] {
        logManager?.trackEvent(event: Event.logInStart)
        do {
            let entitlements = try await service.login(userID: userID)
            logManager?.trackEvent(event: Event.logInSuccess(entitlements: entitlements))
            updateActiveEntitlements(entitlements: entitlements)
            
            if let attributes {
                try await updateProfileAttributes(attributes: attributes)
            }
            
            return entitlements
        } catch {
            logManager?.trackEvent(event: Event.logInFail(error: error))
            throw error
        }
    }
    
    func logOut() async throws {
        do {
            try await service.logOut()
            entitlements.removeAll()
            configure()
            
            logManager?.trackEvent(event: Event.logOutSuccess)
        } catch {
            logManager?.trackEvent(event: Event.logOutFail(error: error))
            throw error
        }
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        try await service.updateProfileAttributes(attributes: attributes)
    }
    
    enum Event: LoggableEvent {
        case purchaseStart
        case purchaseSuccess(entitlements: [PurchasedEntitlement])
        case purchaseFail(error: Error)
        case restorePurchaseStart
        case restorePurchaseSuccess(entitlements: [PurchasedEntitlement])
        case restorePurchaseFail(error: Error)
        case getProductsStart
        case getProductsSuccess(products: [AnyProduct])
        case getProductsFail(error: Error)
        case logInStart
        case logInSuccess(entitlements: [PurchasedEntitlement])
        case logInFail(error: Error)
        case logOutSuccess
        case logOutFail(error: Error)
        
        var eventName: String {
            switch self {
            case .purchaseStart:                return "PurMan_Purchase_Start"
            case .purchaseSuccess:              return "PurMan_Purchase_Success"
            case .purchaseFail:                 return "PurMan_Purchase_Fail"
            case .restorePurchaseStart:         return "PurMan_Restore_Start"
            case .restorePurchaseSuccess:       return "PurMan_Restore_Success"
            case .restorePurchaseFail:          return "PurMan_Restore_Fail"
            case .getProductsStart:             return "PurMan_GetProducts_Start"
            case .getProductsSuccess:           return "PurMan_GetProducts_Success"
            case .getProductsFail:              return "PurMan_GetProducts_Fail"
            case .logInStart:                   return "PurMan_LogIn_Start"
            case .logInSuccess:                 return "PurMan_LogIn_Success"
            case .logInFail:                    return "PurMan_LogIn_Fail"
            case .logOutSuccess:                return "PurMan_LogOut_Success"
            case .logOutFail:                   return "PurMan_LogOut_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .purchaseSuccess(let entitlements), .restorePurchaseSuccess(entitlements: let entitlements), .logInSuccess(entitlements: let entitlements):
                return entitlements.eventParameters
            case .getProductsSuccess(products: let products):
                return products.eventParameters
            case .purchaseFail(error: let error), .getProductsFail(error: let error), .restorePurchaseFail(error: let error), .logInFail(error: let error), .logOutFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .purchaseFail, .getProductsFail, .restorePurchaseFail, .logInFail, .logOutFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

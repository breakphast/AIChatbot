//
//  PurchaseManager.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/19/25.
//

import SwiftUI
import StoreKit

protocol PurchaseService: Sendable {
    func listenForTransactions(onTransactionsUpdated: @Sendable ([PurchasedEntitlement]) async -> Void) async
    func getUserEntitlements() async throws -> [PurchasedEntitlement]
    
    func getProducts(productIDs: [String]) async throws -> [AnyProduct]
    func restorePurchase() async throws -> [PurchasedEntitlement]
    func purchaseProduct(productID: String) async throws -> [PurchasedEntitlement]
    
    func login(userID: String) async throws -> [PurchasedEntitlement]
    func logOut() async throws
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws
}

struct MockPurchaseService: PurchaseService {
    let activeEntitlements: [PurchasedEntitlement]
    
    init(activeEntitlements: [PurchasedEntitlement] = []) {
        self.activeEntitlements = activeEntitlements
    }
    
    func listenForTransactions(onTransactionsUpdated: ([PurchasedEntitlement]) async -> Void) async {
        await onTransactionsUpdated(activeEntitlements)
    }
    
    func getUserEntitlements() async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func getProducts(productIDs: [String]) async throws -> [AnyProduct] {
        AnyProduct.mocks.filter { product in
            return productIDs.contains(product.id)
        }
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func purchaseProduct(productID: String) async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func login(userID: String) async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func logOut() async throws {
        
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        
    }
}

struct StoreKitPurchaseService: PurchaseService {
    func listenForTransactions(onTransactionsUpdated: ([PurchasedEntitlement]) async -> Void) async {
        for await update in StoreKit.Transaction.updates {
            if let transaction = try? update.payloadValue {
                await transaction.finish()
                
                if let entitlements = try? await getUserEntitlements() {
                    await onTransactionsUpdated(entitlements)
                }
            }
        }
    }
    
    func getUserEntitlements() async throws -> [PurchasedEntitlement] {
        var activeTransactions: [PurchasedEntitlement] = []
        
        for await verificationResult in StoreKit.Transaction.currentEntitlements {
            
            switch verificationResult {
            case .verified(let transaction):
                let isActive: Bool
                if let expirationDate = transaction.expirationDate {
                    isActive = expirationDate >= Date.now
                } else {
                    isActive = transaction.revocationDate == nil
                }
                
                activeTransactions.append(
                    PurchasedEntitlement(
                        id: transaction.productID,
                        productId: transaction.productID,
                        expirationDate: transaction.expirationDate,
                        isActive: isActive,
                        originalPurchaseDate: transaction.originalPurchaseDate,
                        latestPurchaseDate: transaction.purchaseDate,
                        ownershipType: EntitlementOwnershipOption(type: transaction.ownershipType),
                        isSandbox: transaction.environment == .sandbox,
                        isVerified: true
                    )
                )
            case .unverified:
                break
            }
        }
        
        return activeTransactions
    }
    
    func getProducts(productIDs: [String]) async throws -> [AnyProduct] {
        let products = try await Product.products(for: productIDs)
        return products.compactMap({ AnyProduct(storeKitProduct: $0) })
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        try await AppStore.sync()
        return try await getUserEntitlements()
    }
    
    func purchaseProduct(productID: String) async throws -> [PurchasedEntitlement] {
        let products = try await Product.products(for: [productID])
        
        guard let product = products.first else {
            throw Error.productNotFound
        }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verificationResult):
            let transaction = try verificationResult.payloadValue
            await transaction.finish()
            
            return try await getUserEntitlements()
        case .userCancelled:
            throw Error.userCancelsPurchase
        default:
            throw Error.productNotFound
        }
    }
    
    func login(userID: String) async throws -> [PurchasedEntitlement] {
        try await getUserEntitlements()
        // StoreKit does not require user profile/login
    }
    
    func logOut() async throws {
        // StoreKit does not require user profile/login
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        // StoreKit does not require user profile/login
    }
    
    enum Error: LocalizedError {
        case productNotFound, userCancelsPurchase
    }
}

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

import RevenueCat

struct RevenueCatPurchaseService: PurchaseService {
    
    init(apiKey: String, logLevel: LogLevel = .warn) {
        Purchases.configure(withAPIKey: apiKey)
        Purchases.logLevel = logLevel
        Purchases.shared.attribution.collectDeviceIdentifiers()
    }
    func listenForTransactions(onTransactionsUpdated: @Sendable ([PurchasedEntitlement]) async -> Void) async {
        for await customerInfo in Purchases.shared.customerInfoStream {
            let entitlements = customerInfo.entitlements.all.asPurchasedEntitlements()
            await onTransactionsUpdated(entitlements)
        }
    }
    
    func getUserEntitlements() async throws -> [PurchasedEntitlement] {
        let customerInfo = try await Purchases.shared.customerInfo()
        let entitlements = customerInfo.entitlements.all.asPurchasedEntitlements()
        return entitlements
    }
    
    func getProducts(productIDs: [String]) async throws -> [AnyProduct] {
        let products = await Purchases.shared.products(productIDs)
        return products.map { AnyProduct(revenueCatProduct: $0 )}
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        let customerInfo = try await Purchases.shared.restorePurchases()
        let entitlements = customerInfo.entitlements.all.asPurchasedEntitlements()
        return entitlements
    }
    
    func purchaseProduct(productID: String) async throws -> [PurchasedEntitlement] {
        guard let product = await Purchases.shared.products([productID]).first else {
            throw PurchaseError.productNotFound
        }
        
        let result = try await Purchases.shared.purchase(product: product)
        let customerInfo = result.customerInfo
        let entitlements = customerInfo.entitlements.all.asPurchasedEntitlements()
        return entitlements
    }
    
    func login(userID: String) async throws -> [PurchasedEntitlement] {
        let (customerInfo, _) = try await Purchases.shared.logIn(userID)
        let entitlements = customerInfo.entitlements.all.asPurchasedEntitlements()
        return entitlements
    }
    
    func logOut() async throws {
        _ = try await Purchases.shared.logOut()
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        if let email = attributes.email {
            Purchases.shared.attribution.setEmail(email)
        }
        if let firebaseAppInstanceID = attributes.firebaseAppInstanceID {
            Purchases.shared.attribution.setFirebaseAppInstanceID(firebaseAppInstanceID)
        }
        
        if let mixpanelDistinctID = attributes.mixpanelDistinctID {
            Purchases.shared.attribution.setMixpanelDistinctID(mixpanelDistinctID)
        }
    }
}

struct PurchaseProfileAttributes {
    init(email: String? = nil, firebaseAppInstanceID: String? = nil, mixpanelDistinctID: String? = nil) {
        self.email = email
        self.firebaseAppInstanceID = firebaseAppInstanceID
        self.mixpanelDistinctID = mixpanelDistinctID
    }
    
    let email: String?
    let firebaseAppInstanceID: String?
    let mixpanelDistinctID: String?
}

enum PurchaseError: LocalizedError {
    case productNotFound, userCancelsPurchase
}

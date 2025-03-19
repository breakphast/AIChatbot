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
    func getUserEntitlements() async -> [PurchasedEntitlement]
    
    func getProducts(productIDs: [String]) async throws -> [AnyProduct]
    func restorePurchase() async throws -> [PurchasedEntitlement]
    func purchaseProduct(productID: String) async throws -> [PurchasedEntitlement]
}

struct MockPurchaseService: PurchaseService {
    let activeEntitlements: [PurchasedEntitlement]
    
    init(activeEntitlements: [PurchasedEntitlement] = []) {
        self.activeEntitlements = activeEntitlements
    }
    
    func listenForTransactions(onTransactionsUpdated: ([PurchasedEntitlement]) async -> Void) async {
        await onTransactionsUpdated(activeEntitlements)
    }
    
    func getUserEntitlements() async -> [PurchasedEntitlement] {
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
}

struct StoreKitPurchaseService: PurchaseService {
    func listenForTransactions(onTransactionsUpdated: ([PurchasedEntitlement]) async -> Void) async {
        for await update in StoreKit.Transaction.updates {
            if let transaction = try? update.payloadValue {
                await transaction.finish()
                
                let entitlements = await getUserEntitlements()
                await onTransactionsUpdated(entitlements)
            }
        }
    }
    
    func getUserEntitlements() async -> [PurchasedEntitlement] {
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
        return await getUserEntitlements()
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
            
            return await getUserEntitlements()
        case .userCancelled:
            throw Error.userCancelsPurchase
        default:
            throw Error.productNotFound
        }
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
    
    init(service: PurchaseService, logManager: LogManager? = nil) {
        self.service = service
        self.logManager = logManager
        self.configure()
    }
    
    private func configure() {
        Task {
            let entitlements = await service.getUserEntitlements()
            updateActiveEntitlements(entitlements: entitlements)
        }
        Task {
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
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .purchaseSuccess(let entitlements), .restorePurchaseSuccess(entitlements: let entitlements):
                return entitlements.eventParameters
            case .getProductsSuccess(products: let products):
                return products.eventParameters
            case .purchaseFail(error: let error), .getProductsFail(error: let error), .restorePurchaseFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .purchaseFail, .getProductsFail, .restorePurchaseFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

//
//  StoreKitPurchaseService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/21/25.
//

import SwiftUI
import StoreKit

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

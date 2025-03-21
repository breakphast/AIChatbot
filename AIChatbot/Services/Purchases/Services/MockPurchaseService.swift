//
//  MockPurchaseService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/21/25.
//

import SwiftUI

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

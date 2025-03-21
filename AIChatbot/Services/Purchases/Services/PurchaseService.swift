//
//  PurchaseService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/21/25.
//

import SwiftUI

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

//
//  RevenueCatPurchaseService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/21/25.
//

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

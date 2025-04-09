//
//  PaywallInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/8/25.
//

import SwiftUI
import StoreKit

@MainActor
protocol PaywallInteractor {
    var activeTests: ActiveABTests { get }
    
    func purchaseProduct(productID: String) async throws -> [PurchasedEntitlement]
    func restorePurchase() async throws -> [PurchasedEntitlement]
    func getProducts(productIDs: [String]) async throws -> [AnyProduct]
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: PaywallInteractor { }

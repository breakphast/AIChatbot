//
//  StoreKitPaywallView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/19/25.
//

import SwiftUI
import StoreKit

struct StoreKitPaywallView: View {
    var productIDs: [String] = EntitlementOption.allProductIDs
    var inAppPurchaseStart: ((Product) async -> Void)?
    var onInAppPurchaseCompletion: ((Product, Result<Product.PurchaseResult, any Error>) async -> Void)?
    
    var body: some View {
        SubscriptionStoreView(productIDs: EntitlementOption.allProductIDs) {
            VStack(spacing: 8) {
                Text("AI Chat 🤖")
                    .font(.largeTitle.bold())
                
                Text("Get premium access to unlock all features.")
                    .font(.subheadline)
            }
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .containerBackground(Color.accent.gradient, for: .subscriptionStore)
        }
        .storeButton(.visible, for: .restorePurchases)
        .subscriptionStoreControlStyle(.prominentPicker)
        .onInAppPurchaseStart(perform: inAppPurchaseStart)
        .onInAppPurchaseCompletion(perform: onInAppPurchaseCompletion)
    }
}

#Preview {
    StoreKitPaywallView(inAppPurchaseStart: nil, onInAppPurchaseCompletion: nil)
}

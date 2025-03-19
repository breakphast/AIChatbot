//
//  PaywallView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/19/25.
//

import SwiftUI
import StoreKit

enum EntitlementOption: Codable, CaseIterable {
    case yearly
    
    var productID: String {
        switch self {
        case .yearly:
            return "devsmond.AIChatBot.yearly"
        }
    }
    
    static var allProductIDs: [String] {
        EntitlementOption.allCases.map { $0.productID }
    }
}

struct PaywallView: View {
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        StoreKitPaywallView(
            inAppPurchaseStart: onPurchaseStart,
            onInAppPurchaseCompletion: onPurchaseComplete
        )
        .screenAppearAnalytics(name: "Paywall")
    }
    
    private func onPurchaseStart(product: StoreKit.Product) {
        let product = AnyProduct(storeKitProduct: product)
        logManager.trackEvent(event: Event.purchaseStart(product: product))
    }
    
    private func onPurchaseComplete(product: StoreKit.Product, result: Result<Product.PurchaseResult, any Error>) {
        let product = AnyProduct(storeKitProduct: product)
        
        switch result {
        case .success(let value):
            switch value {
            case .success:
                logManager.trackEvent(event: Event.purchaseSuccess(product: product))
                dismiss()
            case .pending:
                logManager.trackEvent(event: Event.purchasePending(product: product))
            case .userCancelled:
                logManager.trackEvent(event: Event.purchaseCancelled(product: product))
            default:
                logManager.trackEvent(event: Event.purchaseUnknown(product: product))
            }
        case .failure(let error):
            logManager.trackEvent(event: Event.purchaseFail(error: error))
        }
    }
    
    enum Event: LoggableEvent {
        case purchaseStart(product: AnyProduct)
        case purchaseSuccess(product: AnyProduct)
        case purchasePending(product: AnyProduct)
        case purchaseCancelled(product: AnyProduct)
        case purchaseUnknown(product: AnyProduct)
        case purchaseFail(error: Error)
        
        var eventName: String {
            switch self {
            case .purchaseStart:            return "Paywall_Purchase_Start"
            case .purchaseSuccess:          return "Paywall_Purchase_Success"
            case .purchasePending:          return "Paywall_Purchase_Pending"
            case .purchaseCancelled:        return "Paywall_Purchase_Cancelled"
            case .purchaseUnknown:          return "Paywall_Purchase_Unknown"
            case .purchaseFail:             return "Paywall_Purchase_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .purchaseStart(product: let product), .purchasePending(product: let product), .purchaseSuccess(product: let product), .purchaseCancelled(product: let product), .purchaseUnknown(product: let product):
                return product.eventParameters
            case .purchaseFail(error: let error):
                return error.eventParameters
            }
        }
        
        var type: LogType {
            switch self {
            case .purchaseFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

struct StoreKitPaywallView: View {
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
    PaywallView()
        .previewEnvironment()
}

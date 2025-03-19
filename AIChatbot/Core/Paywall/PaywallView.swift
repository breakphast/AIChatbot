//
//  PaywallView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/19/25.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(PurchaseManager.self) private var purchaseManager
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var products: [AnyProduct] = []
    @State private var productIDs: [String] = EntitlementOption.allProductIDs
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        ZStack {
            if products.isEmpty {
                ProgressView()
            } else {
                CustomPaywallView(
                    products: products,
                    backButtonPressed: onBackButtonPressed,
                    restorePurchasePressed: onRestorePurchasePressed,
                    purchaseProductPressed: onPurchaseProductPressed
                )
            }
        }
        .screenAppearAnalytics(name: "Paywall")
        .showCustomAlert(alert: $showAlert)
        .task {
            await onLoadProducts()
        }
    }
    
    private func onLoadProducts() async {
        do {
            products = try await purchaseManager.getProducts(productIDs: productIDs)
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
    
    private func onBackButtonPressed() {
        logManager.trackEvent(event: Event.backButtonPressed)
        dismiss()
    }
    
    private func onRestorePurchasePressed() {
        logManager.trackEvent(event: Event.restorePurchaseStart)
        Task {
            do {
                let entitlements = try await purchaseManager.restorePurchase()
                if entitlements.hasActiveEntitlement {
                    dismiss()
                }
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func onPurchaseProductPressed(product: AnyProduct) {
        logManager.trackEvent(event: Event.purchaseStart(product: product))
        Task {
            do {
                let entitlements = try await purchaseManager.purchaseProduct(productID: product.id)
                logManager.trackEvent(event: Event.purchaseSuccess(product: product))
                if entitlements.hasActiveEntitlement {
                    dismiss()
                }
            } catch {
                logManager.trackEvent(event: Event.purchaseFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
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
        case loadProductsStart
        case restorePurchaseStart
        case backButtonPressed
        
        var eventName: String {
            switch self {
            case .purchaseStart:            return "Paywall_Purchase_Start"
            case .purchaseSuccess:          return "Paywall_Purchase_Success"
            case .purchasePending:          return "Paywall_Purchase_Pending"
            case .purchaseCancelled:        return "Paywall_Purchase_Cancelled"
            case .purchaseUnknown:          return "Paywall_Purchase_Unknown"
            case .purchaseFail:             return "Paywall_Purchase_Fail"
            case .loadProductsStart:        return "Paywall_Load_Start"
            case .restorePurchaseStart:     return "Paywall_Restore_Start"
            case .backButtonPressed:        return "Paywall_BackButton_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .purchaseStart(product: let product), .purchasePending(product: let product), .purchaseSuccess(product: let product), .purchaseCancelled(product: let product), .purchaseUnknown(product: let product):
                return product.eventParameters
            case .purchaseFail(error: let error):
                return error.eventParameters
            default:
                return nil
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

#Preview {
    PaywallView()
        .previewEnvironment()
}

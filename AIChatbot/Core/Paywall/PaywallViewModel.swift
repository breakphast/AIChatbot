//
//  PaywallInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/27/25.
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

@MainActor
@Observable
class PaywallViewModel {
    private let interactor: PaywallInteractor
    
    var products: [AnyProduct] = []
    var productIDs: [String] = EntitlementOption.allProductIDs
    var showAlert: AnyAppAlert?
    
    init(interactor: PaywallInteractor) {
        self.interactor = interactor
    }
    
    var activeTests: ActiveABTests {
        interactor.activeTests
    }
    
    func onLoadProducts() async {
        do {
            products = try await interactor.getProducts(productIDs: productIDs)
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
    
    func onBackButtonPressed(onDismiss: () -> Void) {
        interactor.trackEvent(event: Event.backButtonPressed)
        onDismiss()
    }
    
    func onRestorePurchasePressed(onDismiss: @escaping () -> Void) {
        interactor.trackEvent(event: Event.restorePurchaseStart)
        Task {
            do {
                let entitlements = try await interactor.restorePurchase()
                if entitlements.hasActiveEntitlement {
                    onDismiss()
                }
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func onPurchaseProductPressed(product: AnyProduct, onDismiss: @escaping () -> Void) {
        interactor.trackEvent(event: Event.purchaseStart(product: product))
        Task {
            do {
                let entitlements = try await interactor.purchaseProduct(productID: product.id)
                interactor.trackEvent(event: Event.purchaseSuccess(product: product))
                if entitlements.hasActiveEntitlement {
                    onDismiss()
                }
            } catch {
                interactor.trackEvent(event: Event.purchaseFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func onPurchaseStart(product: StoreKit.Product) {
        let product = AnyProduct(storeKitProduct: product)
        interactor.trackEvent(event: Event.purchaseStart(product: product))
    }
    
    func onPurchaseComplete(product: StoreKit.Product, result: Result<Product.PurchaseResult, any Error>, onDismiss: @escaping () -> Void) {
        let product = AnyProduct(storeKitProduct: product)
        
        switch result {
        case .success(let value):
            switch value {
            case .success:
                interactor.trackEvent(event: Event.purchaseSuccess(product: product))
                onDismiss()
            case .pending:
                interactor.trackEvent(event: Event.purchasePending(product: product))
            case .userCancelled:
                interactor.trackEvent(event: Event.purchaseCancelled(product: product))
            default:
                interactor.trackEvent(event: Event.purchaseUnknown(product: product))
            }
        case .failure(let error):
            interactor.trackEvent(event: Event.purchaseFail(error: error))
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

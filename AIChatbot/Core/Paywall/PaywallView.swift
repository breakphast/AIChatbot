//
//  PaywallView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/19/25.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: PaywallViewModel
    
    var body: some View {
        ZStack {
            switch viewModel.activeTests.paywallTest {
            case .custom:
                if viewModel.products.isEmpty {
                    ProgressView()
                } else {
                    CustomPaywallView(
                        products: viewModel.products,
                        backButtonPressed: {
                            viewModel.onBackButtonPressed {
                                dismiss()
                            }
                        },
                        restorePurchasePressed: {
                            viewModel.onRestorePurchasePressed {
                                dismiss()
                            }
                        },
                        purchaseProductPressed: { product in
                            viewModel.onPurchaseProductPressed(product: product) {
                                dismiss()
                            }
                        }
                    )
                }
            case .revenueCat:
                RevenueCatPaywallView()
            case .storeKit:
                StoreKitPaywallView(
                    inAppPurchaseStart: { product in
                        viewModel.onPurchaseStart(product: product)
                    },
                    onInAppPurchaseCompletion: { (product, result) in
                        viewModel.onPurchaseComplete(
                            product: product,
                            result: result) {
                                dismiss()
                            }
                    }
                )
            }
        }
        .screenAppearAnalytics(name: "Paywall")
        .showCustomAlert(alert: $viewModel.showAlert)
        .task {
            await viewModel.onLoadProducts()
        }
    }
}

#Preview("Custom") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(paywallTest: .custom)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return builder.paywallView()
        .previewEnvironment()
}

#Preview("RevenueCat") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(paywallTest: .revenueCat)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return builder.paywallView()
        .previewEnvironment()
}
#Preview("StoreKit") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(paywallTest: .storeKit)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return builder.paywallView()
        .previewEnvironment()
}

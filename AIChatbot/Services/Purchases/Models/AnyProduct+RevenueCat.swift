//
//  AnyProduct+RevenueCat.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/20/25.
//

import RevenueCat

public extension AnyProduct {

    init(revenueCatProduct product: RevenueCat.StoreProduct) {
        self.init(
            id: product.productIdentifier,
            title: product.localizedTitle,
            subtitle: product.localizedDescription,
            priceString: product.localizedPriceString,
            productDuration: ProductDurationOption(unit: product.subscriptionPeriod?.unit)
        )
    }

}

extension ProductDurationOption {

    init?(unit: RevenueCat.SubscriptionPeriod.Unit?) {
        if let unit {
            switch unit {
            case .day:
                self = .day
            case .week:
                self = .week
            case .month:
                self = .month
            case .year:
                self = .year
            default:
                return nil
            }
        } else {
            return nil
        }
    }
}

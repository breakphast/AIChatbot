//
//  CustomPaywallView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/19/25.
//

import SwiftUI

struct CustomPaywallView: View {
    var products: [AnyProduct] = []
    var title = "Try Premium Today!"
    var subtitle = "Unlock unlimited access and exclusive features for premium mmebers."
    
    var backButtonPressed: () -> Void = { }
    var restorePurchasePressed: () -> Void = { }
    var purchaseProductPressed: (AnyProduct) -> Void = { _ in }
    
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                
                VStack(spacing: 24) {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    
                    Text(subtitle)
                        .font(.subheadline)
                }
                .foregroundStyle(.white)
                .padding(40)
                
                VStack(spacing: 8) {
                    ForEach(products) { product in
                        productRow(product: product)
                    }
                    Text("Already have a subscription?\nRestore Purchase")
                        .font(.callout)
                        .fontWeight(.medium)
                        .underline()
                        .foregroundStyle(.white)
                        .anyButton(.plain) {
                            restorePurchasePressed()
                        }
                        .padding(16)
                }
                
                Spacer(minLength: 0)
                Spacer(minLength: 0)
            }
        }
        .multilineTextAlignment(.center)
        .overlay(
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.white)
                .font(.title)
                .padding(8)
                .tappableBackground()
                .anyButton {
                    backButtonPressed()
                }
                .padding(16)
            , alignment: .topLeading
        )
    }
    
    private func productRow(product: AnyProduct) -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.title)
                        .font(.headline)
                    Text(product.priceStringWithDuration)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("START")
                    .badgeButton()
            }
            
            Divider()
            Text(product.subtitle)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 2)
        .anyButton(.press, action: {
            purchaseProductPressed(product)
        })
        .padding(16)
    }
}

#Preview {
    CustomPaywallView(products: AnyProduct.mocks)
}

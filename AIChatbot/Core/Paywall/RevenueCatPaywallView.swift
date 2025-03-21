//
//  RevenueCatPaywallView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/21/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct RevenueCatPaywallView: View {
    var body: some View {
        RevenueCatUI.PaywallView(displayCloseButton: true)
    }
}

#Preview {
    RevenueCatPaywallView()
}

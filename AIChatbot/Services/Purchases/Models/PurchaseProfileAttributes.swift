//
//  PurchaseProfileAttributes.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/21/25.
//

import SwiftUI

struct PurchaseProfileAttributes {
    init(email: String? = nil, firebaseAppInstanceID: String? = nil, mixpanelDistinctID: String? = nil) {
        self.email = email
        self.firebaseAppInstanceID = firebaseAppInstanceID
        self.mixpanelDistinctID = mixpanelDistinctID
    }
    
    let email: String?
    let firebaseAppInstanceID: String?
    let mixpanelDistinctID: String?
}

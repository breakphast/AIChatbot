//
//  Constants.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import Foundation
import Mixpanel

struct Constants {
    static let randomImage = "https://picsum.photos/600/600"
    static let privacyPolicyURL = "https://www.apple.com"
    static let termsOfServiceURL = "https://www.apple.com"
    static let accentColorHex = "#FF5757"
    
    static var mixpanelDistinctID: String? {
        #if MOCK
        return nil
        #else
        return MixpanelService.distinctId
        #endif
    }
    
    static var firebaseAnalyticsAppInstanceID: String? {
        #if MOCK
        return nil
        #else
        FirebaseAnalyticsService.appInstanceID
        #endif
    }
}

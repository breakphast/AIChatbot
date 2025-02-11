//
//  AppView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct AppView: View {
    @AppStorage("showTabBarView") var showTabBar = false
    
    var body: some View {
        AppViewBuilder(
            showTabBar: showTabBar,
            tabBarView: {
                ZStack {
                    Color.red.ignoresSafeArea()
                    Text("Tabbar")
                }
            },
            onboardingView: {
                ZStack {
                    Color.blue.ignoresSafeArea()
                    Text("Onboarding")
                }
            }
        )
    }
}

#Preview("AppView - TabBar") {
    AppView(showTabBar: true)
}

#Preview("AppView - Onboarding") {
    AppView(showTabBar: false)
}

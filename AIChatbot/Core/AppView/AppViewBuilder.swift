//
//  AppViewBuilder.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct AppViewBuilder<TabBarView: View, OnboardingView: View>: View {
    var showTabBar = false
    var tabBarView: () -> TabBarView
    var onboardingView: () -> OnboardingView

    var body: some View {
        ZStack {
            if showTabBar {
                tabBarView()
                    .transition(.move(edge: .trailing))
            } else {
                onboardingView()
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.smooth, value: showTabBar)
    }
}

private struct PreviewView: View {
    @State private var showTabBar = false
    
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
        .onTapGesture {
            showTabBar.toggle()
        }
    }
}
#Preview {
    PreviewView()
}

//
//  TabBarView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct TabBarScreen: Identifiable {
    var id: String {
        title
    }
    let title: String
    let systemImage: String
    @ViewBuilder var screen: () -> AnyView
}

struct TabBarView: View {
    var tabs: [TabBarScreen] = []
    
    var body: some View {
        TabView {
            ForEach(tabs) { tab in
                tab.screen()
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
            }
        }
    }
}

#Preview("Fake Tabs") {
    TabBarView(tabs: [
        TabBarScreen(title: "Explore", systemImage: "eyes", screen: {
            Color.red.any()
        }),
        TabBarScreen(title: "Chats", systemImage: "bubble.left.and.bubble.right.fill", screen: {
            Color.green.any()
        }),
        TabBarScreen(title: "Profile", systemImage: "person.fill", screen: {
            Color.blue.any()
        })
    ])
    .previewEnvironment()
}

#Preview("Real Tabs") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    
    return builder.tabBarView()
        .previewEnvironment()
}

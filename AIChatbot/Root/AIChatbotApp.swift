//
//  AIChatbotApp.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/10/25.
//

import SwiftUI
import Firebase
import SwiftfulUtilities

@main
struct AppEntryPoint {
    static func main() {
        if Utilities.isUnitTesting {
            TestingApp.main()
        } else {
            AIChatCourseApp.main()
        }
    }
}

struct TestingApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Testing")
        }
    }
}

struct AIChatCourseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            Group {
                if Utilities.isUITesting {
                    AppViewForUITesting(container: delegate.dependencies.container)
                } else {
                    delegate.builder.build()
                }
            }
            .environment(delegate.dependencies.logManager)
        }
    }
}

struct AppViewForUITesting: View {
    var container: DependencyContainer
    
    private var rootBuilder: RootBuilder {
        RootBuilder(
            interactor: RootInteractor(container: container),
            loggedInRIB: {
                CoreBuilder(interactor: CoreInteractor(container: container))
            },
            loggedOutRIB: {
                OnbBuilder(interactor: OnbInteractor(container: container))
            }
        )
    }
    
    private var coreBuilder: CoreBuilder {
        CoreBuilder(interactor: CoreInteractor(container: container))
    }
    
    private var startOnAvatarScreen: Bool {
        ProcessInfo.processInfo.arguments.contains("STARTSCREEN_CREATEAVATAR")
    }
    
    var body: some View {
        if startOnAvatarScreen {
            RouterView { router in
                coreBuilder.createAvatarView(router: router)
            }
        } else {
            rootBuilder.build()
        }
    }
}

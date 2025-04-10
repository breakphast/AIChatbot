//
//  RandomView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 4/9/25.
//

import SwiftUI

@MainActor
protocol RandomInteractor {
    
}

extension CoreInteractor: RandomInteractor { }

struct RandomDelegate {
    
}

@MainActor
protocol RandomRouter {
    
}

extension CoreRouter: RandomRouter { }

@MainActor
@Observable
class RandomPresenter {
    private let interactor: RandomInteractor
    private let router: RandomRouter
    
    init(interactor: RandomInteractor, router: RandomRouter) {
        self.interactor = interactor
        self.router = router
    }
}

struct RandomView: View {
    @State var presenter: RandomPresenter
    let delegate: RandomDelegate
    
    var body: some View {
        Text("RANDOM!")
            .screenAppearAnalytics(name: "RandomView")
            .navigationTitle("Random")
    }
}

extension CoreBuilder {
    func randomView(router: AnyRouter, delegate: RandomDelegate) -> some View {
        RandomView(
            presenter: RandomPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showRandomView(delegate: RandomDelegate) {
        router.showScreen(.push) { router in
            builder.randomView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = RandomDelegate()
    
    return RouterView { router in
        builder.randomView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

import SwiftUI

struct SearchDelegate {
    
}

struct SearchView: View {
    
    @State var presenter: SearchPresenter
    let delegate: SearchDelegate
    
    var body: some View {
        Text("Hello, World!")
            .screenAppearAnalytics(name: "SearchView")
    }
}

extension CoreBuilder {
    
    func searchView(router: Router, delegate: SearchDelegate) -> some View {
        SearchView(
            presenter: SearchPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showSearchView(delegate: SearchDelegate) {
        router.showScreen(.push) { router in
            builder.searchView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = SearchDelegate()
    
    return RouterView { router in
        builder.searchView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

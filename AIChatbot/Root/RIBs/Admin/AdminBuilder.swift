import SwiftUI

@MainActor
struct AdminBuilder: Builder {
    let interactor: AdminInteractor
    
    func build() -> AnyView {
        Text("").any()
    }
}

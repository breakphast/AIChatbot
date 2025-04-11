import SwiftUI

struct ChatAvatarDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
    
    var avatar: AvatarModel
}

struct ChatAvatarView: View {
    
    @State var presenter: ChatAvatarPresenter
    let delegate: ChatAvatarDelegate
    
    var body: some View {
        List {
            Section {
                CategoryCellView(title: delegate.avatar.name ?? "")
                    .listStyle(.plain)
                Text(delegate.avatar.characterDescription)
            }
            
            Section {
                ForEach(presenter.avatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: avatar.characterDescription
                    )
                    .anyButton(.highlight, action: {
                        presenter.onAvatarPressed(avatar: avatar)
                    })
                    .removeListRowFormatting()
                }
                .removeListRowFormatting()
            } header: {
                Text("OTHER AVATARS YOU MAY LIKE")
            }
        }
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = ChatAvatarDelegate(avatar: AvatarModel.mock)
    
    return RouterView { router in
        builder.chatAvatarView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

extension CoreBuilder {
    
    func chatAvatarView(router: AnyRouter, delegate: ChatAvatarDelegate) -> some View {
        ChatAvatarView(
            presenter: ChatAvatarPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showChatAvatarView(delegate: ChatAvatarDelegate) {
        router.showScreen(.push) { router in
            builder.chatAvatarView(router: router, delegate: delegate)
        }
    }
    
}

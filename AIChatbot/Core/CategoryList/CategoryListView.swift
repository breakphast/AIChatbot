//
//  CategoryListView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/26/25.
//

import SwiftUI

struct CategoryListDelegate {
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImage
}

struct CategoryListView: View {
    @State var presenter: CategoryListPresenter
    let delegate: CategoryListDelegate
    
    var body: some View {
        List {
            CategoryCellView(
                title: delegate.category.pluralized.capitalized,
                imageName: delegate.imageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormatting()
            
            if presenter.isLoading {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else if presenter.avatars.isEmpty {
                Text("No avatars found 😢")
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else {
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
            }
        }
        .screenAppearAnalytics(name: "CategoryList")
        .ignoresSafeArea()
        .listStyle(.plain)
        .task {
            await presenter.loadAvatars(category: delegate.category)
        }
    }
}

#Preview("Has data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService()))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CategoryListDelegate()
    
    return RouterView { router in
        builder.categoryListView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

#Preview("No data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(avatars: [])))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CategoryListDelegate()
    
    return RouterView { router in
        builder.categoryListView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

#Preview("Slow loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(delay: 8)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CategoryListDelegate()
    
    return RouterView { router in
        builder.categoryListView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

#Preview("Error loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(delay: 4, showError: true)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CategoryListDelegate()
    
    return RouterView { router in
        builder.categoryListView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

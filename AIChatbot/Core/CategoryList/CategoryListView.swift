//
//  CategoryListView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/26/25.
//

import SwiftUI

struct CategoryListDelegate {
    var path: Binding<[TabBarPathOption]>
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImage
}

struct CategoryListView: View {
    @Environment(CoreBuilder.self) private var builder
    @State var viewModel: CategoryListViewModel
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
            
            if viewModel.isLoading {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else if viewModel.avatars.isEmpty {
                Text("No avatars found 😢")
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else {
                ForEach(viewModel.avatars, id: \.self) { avatar in
                    builder.customListCellView(
                        delegate: CustomListCellDelegate(
                            imageName: avatar.profileImageName,
                            title: avatar.name,
                            subtitle: avatar.characterDescription
                        )
                    )
                    .anyButton(.highlight, action: {
                        viewModel.onAvatarPressed(avatar: avatar, path: delegate.path)
                    })
                    .removeListRowFormatting()
                }
            }
        }
        .showCustomAlert(alert: $viewModel.showAlert)
        .screenAppearAnalytics(name: "CategoryList")
        .ignoresSafeArea()
        .listStyle(.plain)
        .task {
            await viewModel.loadAvatars(category: delegate.category)
        }
    }
}

#Preview("Has data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService()))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CategoryListDelegate(path: .constant([]))
    
    return builder.categoryListView(delegate: delegate)
        .previewEnvironment()
}

#Preview("No data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(avatars: [])))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CategoryListDelegate(path: .constant([]))
    
    return builder.categoryListView(delegate: delegate)
        .previewEnvironment()
}

#Preview("Slow loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(delay: 8)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CategoryListDelegate(path: .constant([])) 
    
    return builder.categoryListView(delegate: delegate)
        .previewEnvironment()
}

#Preview("Error loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(delay: 4, showError: true)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CategoryListDelegate(path: .constant([]))
    
    return builder.categoryListView(delegate: delegate)
        .previewEnvironment()
}

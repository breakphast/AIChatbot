//
//  ExploreView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct ExploreView: View {
    @State var presenter: ExplorePresenter
    
    var body: some View {
        List {
            if presenter.featuredAvatars.isEmpty && presenter.popularAvatars.isEmpty {
                ZStack {
                    if presenter.isLoadingFeatured || presenter.isLoadingPopular {
                        loadingIndicator
                    } else {
                        errorMessageView
                    }
                }
                .removeListRowFormatting()
            }
            
            if !presenter.popularAvatars.isEmpty, presenter.categoryRowTestType == .top {
                categorySection
            }
            
            if !presenter.featuredAvatars.isEmpty {
                featuredSection
            }
            
            if presenter.createAvatarTest {
                newAvatarButton
            }
            
            if !presenter.popularAvatars.isEmpty {
                if presenter.categoryRowTestType == .original {
                    categorySection
                }
                popularSection
            }
        }
        .navigationTitle("Explore")
        .screenAppearAnalytics(name: "ExploreView")
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                if presenter.showDevSettingsButton == true {
                    devSettingsButton
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if presenter.showNotificationButton {
                    pushNotificationButton
                }
            }
        })
        .task {
            await presenter.loadFeaturedAvatars()
        }
        .task {
            await presenter.loadPopularAvatars()
        }
        .task {
            await presenter.handleShowPushNotificationButton()
        }
        .onFirstAppear {
            presenter.schedulePushNotifications()
            presenter.showCreateAccountScreenIfNeeded()
        }
        .onOpenURL { url in
            presenter.handleDeepLink(url: url)
        }
    }
    
    private var pushNotificationButton: some View {
        Image(systemName: "bell.fill")
            .font(.headline)
            .padding(4)
            .tappableBackground()
            .foregroundStyle(.accent)
            .anyButton {
                presenter.onPushNotificationButtonPressed()
            }
    }
    
    private var devSettingsButton: some View {
        Text("DEV 🤫")
            .badgeButton()
            .anyButton(.press) {
                presenter.onDevSettingsPressed()
            }
    }
    
    private var newAvatarButton: some View {
        HStack {
            Text("Create New Avatar")
            Image(systemName: "plus")
        }
        .callToActionButton()
        .anyButton {
            presenter.onCreateAvatarPressed()
        }
        .removeListRowFormatting()
    }
    
    private var loadingIndicator: some View {
        ProgressView()
            .padding(40)
            .frame(maxWidth: .infinity)
            .removeListRowFormatting()
    }
    
    private var errorMessageView: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Error")
                .font(.headline)
            Text("Please check your internet connection and try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                presenter.onTryAgainPressed()
            }
            .tint(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .removeListRowFormatting()
    }
    
    private var featuredSection: some View {
        Section {
            ZStack {
                CarouselView(items: presenter.featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subtitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    .anyButton {
                        presenter.onAvatarPressed(avatar: avatar)
                    }
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Featured")
        }
    }
    
    private var categorySection: some View {
        Section {
            ZStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(presenter.categories, id: \.self) { category in
                            let imageName = presenter.popularAvatars.last(where: { $0.characterOption == category })?.profileImageName
                            
                            if let imageName {
                                CategoryCellView(
                                    title: category.pluralized.capitalized,
                                    imageName: imageName
                                )
                                .anyButton {
                                    presenter.onCategoryPressed(category: category, imageName: imageName)
                                }
                            }
                        }
                    }
                }
                .frame(height: 140)
                .scrollIndicators(.hidden)
                .scrollTargetLayout()
                .scrollTargetBehavior(.viewAligned)
            }
            .removeListRowFormatting()
        } header: {
            Text("Categories")
        }
    }
    
    private var popularSection: some View {
        Section {
            ForEach(presenter.popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
                .anyButton(.highlight) {
                    presenter.onAvatarPressed(avatar: avatar)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Popular")
        }
    }
}

//#Preview("Has Data") {
//    let container = DevPreview.shared.container()
//    container.register(RemoteAvatarService.self, service: MockAvatarService())
//    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
//    
//    return RouterView { router in
//        builder.exploreView(router: router)
//    }
//    .previewEnvironment()
//}

//#Preview("CategoryRowTest: Original") {
//    let container = DevPreview.shared.container()
//    container.register(RemoteAvatarService.self, service: MockAvatarService())
//    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .original)))
//    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
//    
//    return RouterView { router in
//        builder.exploreView(router: router)
//    }
//    .previewEnvironment()
//}

#Preview("CreateAvatarTest") {
    let container = DevPreview.shared.container()
    container.register(RemoteAvatarService.self, service: MockAvatarService())
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(createAvatarTest: true)))
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.exploreView(router: router)
    }
    .previewEnvironment()
}

//#Preview("CategoryRowTest: Hidden") {
//    let container = DevPreview.shared.container()
//    container.register(RemoteAvatarService.self, service: MockAvatarService())
//    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .hidden)))
//    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
//    
//    return RouterView { router in
//        builder.exploreView(router: router)
//    }
//    .previewEnvironment()
//}
//
//#Preview("Has Data w/ Create Acct Test") {
//    let container = DevPreview.shared.container()
//    container.register(RemoteAvatarService.self, service: MockAvatarService())
//    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
//    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(createAccountTest: true)))
//    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
//    
//    return RouterView { router in
//        builder.exploreView(router: router)
//    }
//    .previewEnvironment()
//}
//
//#Preview("No Data") {
//    let container = DevPreview.shared.container()
//    container.register(RemoteAvatarService.self, service: MockAvatarService(avatars: [], delay: 2))
//    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
//    
//    return RouterView { router in
//        builder.exploreView(router: router)
//    }
//    .previewEnvironment()
//}
//
//#Preview("Slow loading") {
//    let container = DevPreview.shared.container()
//    container.register(RemoteAvatarService.self, service: MockAvatarService(delay: 10))
//    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
//    
//    return RouterView { router in
//        builder.exploreView(router: router)
//    }
//    .previewEnvironment()
//}

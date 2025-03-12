//
//  ExploreView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct ExploreView: View {
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    
    @State private var categories = CharacterOption.allCases
    
    @State private var featuredAvatars = [AvatarModel]()
    @State private var popularAvatars = [AvatarModel]()
    @State private var isLoadingFeatured: Bool = false
    @State private var isLoadingPopular: Bool = false
    @State private var showDevSettings: Bool = false
    
    @State private var path: [NavigationPathOption] = []
    
    private var showDevSettingsButton: Bool {
        #if DEV || MOCK
        true
        #else
        false
        #endif
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if featuredAvatars.isEmpty && popularAvatars.isEmpty {
                    ZStack {
                        if isLoadingFeatured || isLoadingPopular {
                            loadingIndicator
                        } else {
                            errorMessageView
                        }
                    }
                    .removeListRowFormatting()
                }
                
                if !featuredAvatars.isEmpty {
                    featuredSection
                }
                if !popularAvatars.isEmpty {
                    categorySection
                    popularSection
                }
            }
            .sheet(isPresented: $showDevSettings, content: {
                DevSettingsView()
            })
            .navigationDestinationForCoreModule(path: $path)
            .navigationTitle("Explore")
            .screenAppearAnalytics(name: "ExploreView")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if showDevSettingsButton {
                        devSettingsButton
                    }
                }
            })
            .task {
                await loadFeaturedAvatars()
            }
            .task {
                await loadPopularAvatars()
            }
        }
    }
    
    private var devSettingsButton: some View {
        Text("DEV 🤫")
            .badgeButton()
            .anyButton(.press) {
                onDevSettingsPressed()
            }
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
                onTryAgainPressed()
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
                CarouselView(items: featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subtitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    .anyButton {
                        onAvatarPressed(avatar: avatar)
                    }
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Featured Avatars")
        }
    }
    
    private var categorySection: some View {
        Section {
            ZStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            let imageName = popularAvatars.last(where: { $0.characterOption == category })?.profileImageName
                            
                            if let imageName {
                                CategoryCellView(
                                    title: category.pluralized.capitalized,
                                    imageName: imageName
                                )
                                .anyButton {
                                    onCategoryPressed(category: category, imageName: imageName)
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
            ForEach(popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
                .anyButton(.highlight) {
                    onAvatarPressed(avatar: avatar)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Popular")
        }
    }
    
    enum Event: LoggableEvent {
        case loadFeaturedAvatarsStart
        case loadFeaturedAvatarsSuccess(count: Int)
        case loadFeaturedAvatarsFail(error: Error)
        case loadPopularAvatarsStart
        case loadPopularAvatarsSuccess(count: Int)
        case loadPopularAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel)
        case categoryPressed(category: CharacterOption)
        case tryAgainPressed
        case devSettingsPressed
        
        var eventName: String {
            switch self {
            case .loadFeaturedAvatarsStart:            return "Explore_LoadFeatured_Start"
            case .loadFeaturedAvatarsSuccess:          return "Explore_LoadFeatured_Success"
            case .loadFeaturedAvatarsFail:             return "Explore_LoadFeatured_Fail"
            case .loadPopularAvatarsStart:             return "Explore_LoadPopular_Start"
            case .loadPopularAvatarsSuccess:           return "Explore_LoadPopular_Success"
            case .loadPopularAvatarsFail:              return "Explore_LoadPopular_Success"
            case .avatarPressed:                       return "Explore_AvatarPressed"
            case .categoryPressed:                     return "Explore_CategoryPressed"
            case .tryAgainPressed:                     return "Explore_TryAgain_Pressed"
            case .devSettingsPressed:                  return "DevSettings_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadFeaturedAvatarsFail(error: let error), .loadPopularAvatarsFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            case .loadFeaturedAvatarsSuccess(count: let count), .loadPopularAvatarsSuccess(count: let count):
                return [
                    "avatars_count": count
                ]
            case .categoryPressed(category: let category):
                return [
                    "category": category.rawValue
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadFeaturedAvatarsFail, .loadPopularAvatarsFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    private func onDevSettingsPressed() {
        showDevSettings = true
        logManager.trackEvent(event: Event.devSettingsPressed)
    }
    
    private func onTryAgainPressed() {
        isLoadingFeatured = true
        isLoadingPopular = true
        logManager.trackEvent(event: Event.tryAgainPressed)
        
        Task {
            await loadFeaturedAvatars()
        }
        Task {
            await loadPopularAvatars()
        }
    }
    
    private func loadFeaturedAvatars() async {
        guard featuredAvatars.isEmpty else { return }
        logManager.trackEvent(event: Event.loadFeaturedAvatarsStart)
        isLoadingFeatured = true
        
        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
            isLoadingFeatured = false
            logManager.trackEvent(event: Event.loadFeaturedAvatarsSuccess(count: featuredAvatars.count))
        } catch {
            print("Error loading featured avatars: \(error)")
            logManager.trackEvent(event: Event.loadFeaturedAvatarsFail(error: error))
        }
    }
    
    private func loadPopularAvatars() async {
        guard popularAvatars.isEmpty else { return }
        logManager.trackEvent(event: Event.loadPopularAvatarsStart)
        isLoadingPopular = true
        
        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
            isLoadingPopular = false
            logManager.trackEvent(event: Event.loadPopularAvatarsSuccess(count: popularAvatars.count))
        } catch {
            print("Error loading popular avatars: \(error)")
            logManager.trackEvent(event: Event.loadPopularAvatarsFail(error: error))
        }
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarID: avatar.avatarID, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    private func onCategoryPressed(category: CharacterOption, imageName: String) {
        path.append(.category(category: category, imageName: imageName))
        logManager.trackEvent(event: Event.categoryPressed(category: category))
    }
}

#Preview("Has Data") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService()))
}

#Preview("No Data") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(avatars: [], delay: 2)))
}

#Preview("Slow loading") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(delay: 10)))
}

//
//  ProfileView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/11/25.
//

import SwiftUI

struct ProfileView: View {
    @State var presenter: ProfilePresenter
    
    var body: some View {
        List {
            myInfoSection
            myAvatarSection
        }
        .navigationTitle("Profile")
        .screenAppearAnalytics(name: "ProfileView")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                settingsButton
            }
        }
        .task {
            await presenter.loadData()
        }
    }
    
    private var settingsButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton {
                presenter.onSettingsButtonPressed()
            }
    }
    
    private var myInfoSection: some View {
        Section {
            ZStack {
                Circle()
                    .fill(presenter.currentUser?.profileColorConverted ?? .accent)
            }
            .frame(width: 100, height: 100)
            .frame(maxWidth: .infinity)
            .removeListRowFormatting()
        }
    }
    
    private var myAvatarSection: some View {
        Section {
            if presenter.myAvatars.isEmpty {
                Group {
                    if presenter.isLoading {
                        ProgressView()
                    } else {
                        Text("Click + to create an avatar")
                    }
                }
                .padding(50)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.secondary)
                .removeListRowFormatting()
            } else {
                ForEach(presenter.myAvatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: nil
                    )
                    .anyButton(.highlight, action: {
                        presenter.onAvatarPressed(avatar: avatar)
                    })
                    .removeListRowFormatting()
                }
                .onDelete { indexSet in
                    presenter.onDeleteAvatar(indexSet: indexSet)
                }
            }
        } header: {
            HStack {
                Text("My Avatars")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(.accent)
                    .anyButton {
                        presenter.onNewAvatarButtonPressed()
                    }
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    
    return RouterView { router in
        builder.profileView(router: router)
    }
    .previewEnvironment()
}

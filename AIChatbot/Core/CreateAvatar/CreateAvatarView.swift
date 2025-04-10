//
//  CreateAvatarView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/24/25.
//

import SwiftUI

struct CreateAvatarView: View {
    @State var presenter: CreateAvatarPresenter

    var body: some View {
        List {
            nameSection
            attributesSection
            imageSection
            saveSection
        }
        .navigationTitle("Create Avatar")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
        }
        .screenAppearAnalytics(name: "CreateAvatar")
    }
    
    private var backButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton(.plain) {
                presenter.onBackButtonPressed()
            }
    }
    
    private var nameSection: some View {
        Section {
            TextField("Player 1", text: $presenter.avatarName)
        } header: {
            Text("Name your avatar*")
                .lineLimit(1)
                .minimumScaleFactor(0.3)
        }
    }
    
    private var imageSection: some View {
        Section {
            HStack(alignment: .top, spacing: 8) {
                ZStack {
                    Text("Generate Image")
                        .underline()
                        .foregroundStyle(.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                        .anyButton(.plain) {
                            presenter.onGenerateImagePressed()
                        }
                        .opacity(presenter.isGenerating ? 0 : 1)
                    
                    ProgressView()
                        .tint(.accent)
                        .opacity(presenter.isGenerating ? 1 : 0)
                }
                .disabled(presenter.isGenerating || presenter.avatarName.isEmpty)
                
                avatarIcon
            }
            .removeListRowFormatting()
        }
    }
    
    private var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                isLoading: presenter.isSaving,
                text: "Save") {
                    presenter.onSavePressed()
                }
                .removeListRowFormatting()
                .padding(.top, 24)
                .disabled(presenter.generatedImage == nil || presenter.isSaving)
                .opacity(presenter.generatedImage == nil ? 0.5 : 1.0)
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)
        }
    }
    
    private var attributesSection: some View {
        Section {
            Picker(selection: $presenter.characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("is a...")
            }
            
            Picker(selection: $presenter.characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { action in
                    Text(action.rawValue.capitalized)
                        .tag(action)
                }
            } label: {
                Text("that is...")
            }
            
            Picker(selection: $presenter.characterLocation) {
                ForEach(CharacterLocation.allCases, id: \.self) { location in
                    Text(location.rawValue.capitalized)
                        .tag(location)
                }
            } label: {
                Text("in the...")
            }
        } header: {
            Text("Attributes")
                .lineLimit(1)
                .minimumScaleFactor(0.3)
        }
    }
    
    private var avatarIcon: some View {
        Circle()
            .fill(.secondary.opacity(0.3))
            .overlay {
                ZStack {
                    if let generatedImage = presenter.generatedImage {
                        Image(uiImage: generatedImage)
                            .resizable()
                            .scaledToFill()
                    }
                }
            }
            .clipShape(Circle())
            .frame(maxHeight: 400)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.createAvatarView(router: router)
    }
    .previewEnvironment()
}

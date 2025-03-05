//
//  CreateAvatarView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/24/25.
//

import SwiftUI

struct CreateAvatarView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AIManager.self) private var aiManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    
    @State private var avatarName: String = ""
    @State private var characterOption: CharacterOption = .default
    @State private var characterAction: CharacterAction = .default
    @State private var characterLocation: CharacterLocation = .default
    @State private var isGenerating = false
    @State private var generatedImage: UIImage?
    @State private var isSaving = false
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        NavigationStack {
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
            .showCustomAlert(alert: $showAlert)
        }
    }
    
    private var backButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton(.plain) {
                onBackButtonPressed()
            }
    }
    
    private var nameSection: some View {
        Section {
            TextField("Player 1", text: $avatarName)
        } header: {
            Text("Name your avatar*")
        }
    }
    
    private var imageSection: some View {
        Section {
            HStack(alignment: .top, spacing: 8) {
                ZStack {
                    Text("Generate Image")
                        .underline()
                        .foregroundStyle(.accent)
                        .anyButton(.plain) {
                            onGenerateImagePressed()
                        }
                        .opacity(isGenerating ? 0 : 1)
                    
                    ProgressView()
                        .tint(.accent)
                        .opacity(isGenerating ? 1 : 0)
                }
                .disabled(isGenerating || avatarName.isEmpty)
                
                avatarIcon
            }
            .removeListRowFormatting()
        }
    }
    
    private var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                isLoading: isSaving,
                text: "Save") {
                    onSavePressed()
                }
                .removeListRowFormatting()
                .padding(.top, 24)
                .disabled(generatedImage == nil || isSaving)
                .opacity(generatedImage == nil ? 0.5 : 1.0)
        }
    }
    
    private var attributesSection: some View {
        Section {
            Picker(selection: $characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("is a...")
            }
            
            Picker(selection: $characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { action in
                    Text(action.rawValue.capitalized)
                        .tag(action)
                }
            } label: {
                Text("that is...")
            }
            
            Picker(selection: $characterLocation) {
                ForEach(CharacterLocation.allCases, id: \.self) { location in
                    Text(location.rawValue.capitalized)
                        .tag(location)
                }
            } label: {
                Text("in the...")
            }
        } header: {
            Text("Attributes")
        }
    }
    
    private var avatarIcon: some View {
        Circle()
            .fill(.secondary.opacity(0.3))
            .overlay {
                ZStack {
                    if let generatedImage {
                        Image(uiImage: generatedImage)
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                    }
                }
            }
    }
    
    private func onGenerateImagePressed() {
        isGenerating = true
        
        Task {
            do {
                let prompt = AvatarDescriptionBuilder(
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation
                ).characterDescription
                
                generatedImage = try await aiManager.generateImage(input: prompt)
            } catch {
                print("Error generating image \(error)")
            }
            
            isGenerating = false
        }
    }
    
    private func onSavePressed() {
        guard let generatedImage else { return }
        
        isSaving = true
        
        Task {
            do {
                try TextValidationHelper.checkIfTextIsValid(text: avatarName)
                let uid = try authManager.getAuthID()
                
                let avatar = AvatarModel(
                    avatarID: UUID().uuidString,
                    name: avatarName,
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation,
                    profileImageName: nil,
                    authorID: uid,
                    dateCreated: .now
                )
                
                try await avatarManager.createAvatar(avatar: avatar, image: generatedImage)
                
                dismiss()
                isSaving = false
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func onBackButtonPressed() {
        dismiss()
    }
}

#Preview {
    CreateAvatarView()
        .environment(AIManager(service: MockAIService()))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .environment(AvatarManager(service: MockAvatarService()))
}

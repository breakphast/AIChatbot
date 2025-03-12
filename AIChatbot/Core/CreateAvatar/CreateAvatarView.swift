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
    @Environment(LogManager.self) private var logManager
    
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
            .screenAppearAnalytics(name: "CreateAvatar")
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
    
    enum Event: LoggableEvent {
        case backButtonPressed
        case generateImageStart
        case generateImageSuccess(avatarDescriptionBuilder: AvatarDescriptionBuilder)
        case generateImageFail(error: Error)
        case saveAvatarStart
        case saveAvatarSuccess(avatar: AvatarModel)
        case saveAvatarFail(error: Error)
        
        var eventName: String {
            switch self {
            case .backButtonPressed:            return "CreateAvatar_BackButtonPressed"
            case .generateImageStart:           return "CreateAvatar_GenerateImage_Start"
            case .generateImageSuccess:         return "CreateAvatar_GenerateImage_Success"
            case .generateImageFail:            return "CreateAvatar_GenerateImage_Fail"
            case .saveAvatarStart:              return "CreateAvatar_SaveAvatar_Start"
            case .saveAvatarSuccess:            return "CreateAvatar_SaveAvatar_Success"
            case .saveAvatarFail:               return "CreateAvatar_SaveAvatar_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .generateImageSuccess(avatarDescriptionBuilder: let avatarDescriptionBuilder):
                return avatarDescriptionBuilder.eventParameters
            case .saveAvatarSuccess(avatar: let avatar):
                return avatar.eventParameters
            case .generateImageFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .generateImageFail:
                return .severe
            case .saveAvatarFail:
                return .warning
            default:
                return .analytic
            }
        }
    }
    
    private func onGenerateImagePressed() {
        logManager.trackEvent(event: Event.generateImageStart)
        isGenerating = true
        
        Task {
            do {
                let avatarDescriptionBuilder = AvatarDescriptionBuilder(
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation
                )
                let prompt = avatarDescriptionBuilder.characterDescription
                
                generatedImage = try await aiManager.generateImage(input: prompt)
                logManager.trackEvent(event: Event.generateImageSuccess(avatarDescriptionBuilder: avatarDescriptionBuilder))
            } catch {
                print("Error generating image \(error)")
                logManager.trackEvent(event: Event.generateImageFail(error: error))
            }
            
            isGenerating = false
        }
    }
    
    private func onSavePressed() {
        logManager.trackEvent(event: Event.saveAvatarStart)
        guard let generatedImage else { return }
        
        isSaving = true
        
        Task {
            do {
                try TextValidationHelper.checkIfTextIsValid(text: avatarName)
                let uid = try authManager.getAuthID()
                
                let avatar = AvatarModel.newAvatar(
                    name: avatarName,
                    option: characterOption,
                    action: characterAction,
                    location: characterLocation,
                    authorID: uid
                )
                
                try await avatarManager.createAvatar(avatar: avatar, image: generatedImage)
                logManager.trackEvent(event: Event.saveAvatarSuccess(avatar: avatar))
                
                dismiss()
                isSaving = false
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.saveAvatarFail(error: error))
            }
        }
    }
    
    private func onBackButtonPressed() {
        logManager.trackEvent(event: Event.backButtonPressed)
        dismiss()
    }
}

#Preview {
    CreateAvatarView()
        .environment(AIManager(service: MockAIService()))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .environment(AvatarManager(service: MockAvatarService()))
}

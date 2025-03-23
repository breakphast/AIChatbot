//
//  CreateAvatarView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/24/25.
//

import SwiftUI

@MainActor
@Observable
class CreateAvatarAvatarViewModel {
    private let authManager: AuthManager
    private let aiManager: AIManager
    private let avatarManager: AvatarManager
    private let logManager: LogManager
    
    private(set) var isGenerating = false
    private(set) var generatedImage: UIImage?
    private(set) var isSaving = false
    
    var characterOption: CharacterOption = .default
    var characterAction: CharacterAction = .default
    var characterLocation: CharacterLocation = .default
    var avatarName: String = ""
    var showAlert: AnyAppAlert?
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.aiManager = container.resolve(AIManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
    
    func onGenerateImagePressed() {
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
    
    func onSavePressed(onDismiss: @escaping () -> Void) {
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
                
                onDismiss()
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.saveAvatarFail(error: error))
            }
            
            isSaving = false
        }
    }
    
    func onBackButtonPressed(onDismiss: () -> Void) {
        logManager.trackEvent(event: Event.backButtonPressed)
        onDismiss()
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
}

struct CreateAvatarView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: CreateAvatarAvatarViewModel

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
            .showCustomAlert(alert: $viewModel.showAlert)
            .screenAppearAnalytics(name: "CreateAvatar")
        }
    }
    
    private var backButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton(.plain) {
                viewModel.onBackButtonPressed {
                    dismiss()
                }
            }
    }
    
    private var nameSection: some View {
        Section {
            TextField("Player 1", text: $viewModel.avatarName)
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
                            viewModel.onGenerateImagePressed()
                        }
                        .opacity(viewModel.isGenerating ? 0 : 1)
                    
                    ProgressView()
                        .tint(.accent)
                        .opacity(viewModel.isGenerating ? 1 : 0)
                }
                .disabled(viewModel.isGenerating || viewModel.avatarName.isEmpty)
                
                avatarIcon
            }
            .removeListRowFormatting()
        }
    }
    
    private var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                isLoading: viewModel.isSaving,
                text: "Save") {
                    viewModel.onSavePressed(onDismiss: {
                        dismiss()
                    })
//                    viewModel.onSavePressed {
////                        dismiss()
//                    }
                }
                .removeListRowFormatting()
                .padding(.top, 24)
                .disabled(viewModel.generatedImage == nil || viewModel.isSaving)
                .opacity(viewModel.generatedImage == nil ? 0.5 : 1.0)
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)
        }
    }
    
    private var attributesSection: some View {
        Section {
            Picker(selection: $viewModel.characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("is a...")
            }
            
            Picker(selection: $viewModel.characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { action in
                    Text(action.rawValue.capitalized)
                        .tag(action)
                }
            } label: {
                Text("that is...")
            }
            
            Picker(selection: $viewModel.characterLocation) {
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
                    if let generatedImage = viewModel.generatedImage {
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
    CreateAvatarView(
        viewModel: CreateAvatarAvatarViewModel(container: DevPreview.shared.container)
    )
    .previewEnvironment()
}

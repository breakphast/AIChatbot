//
//  CreateAvatarInteractor.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/26/25.
//

import SwiftUI

@MainActor
protocol CreateAvatarInteractor {
    func trackEvent(event: LoggableEvent)
    func generateImage(input: String) async throws -> UIImage
    func getAuthID() throws -> String
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
}

extension CoreInteractor: CreateAvatarInteractor { }

@MainActor
protocol CreateAvatarRouter {
    func dismissScreen()
    func showAlert(error: Error)
}

extension CoreRouter: CreateAvatarRouter { }

@MainActor
@Observable
class CreateAvatarViewModel {
    private let interactor: CreateAvatarInteractor
    private let router: CreateAvatarRouter
    
    private(set) var isGenerating = false
    private(set) var generatedImage: UIImage?
    private(set) var isSaving = false
    
    var characterOption: CharacterOption = .default
    var characterAction: CharacterAction = .default
    var characterLocation: CharacterLocation = .default
    var avatarName: String = ""
    
    init(interactor: CreateAvatarInteractor, router: CreateAvatarRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onGenerateImagePressed() {
        interactor.trackEvent(event: Event.generateImageStart)
        isGenerating = true
        
        Task {
            do {
                let avatarDescriptionBuilder = AvatarDescriptionBuilder(
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation
                )
                let prompt = avatarDescriptionBuilder.characterDescription
                
                generatedImage = try await interactor.generateImage(input: prompt)
                interactor.trackEvent(event: Event.generateImageSuccess(avatarDescriptionBuilder: avatarDescriptionBuilder))
            } catch {
                print("Error generating image \(error)")
                interactor.trackEvent(event: Event.generateImageFail(error: error))
            }
            
            isGenerating = false
        }
    }
    
    func onSavePressed() {
        interactor.trackEvent(event: Event.saveAvatarStart)
        guard let generatedImage else { return }
        
        isSaving = true
        
        Task {
            do {
                try TextValidationHelper.checkIfTextIsValid(text: avatarName)
                let uid = try interactor.getAuthID()
                
                let avatar = AvatarModel.newAvatar(
                    name: avatarName,
                    option: characterOption,
                    action: characterAction,
                    location: characterLocation,
                    authorID: uid
                )
                
                try await interactor.createAvatar(avatar: avatar, image: generatedImage)
                interactor.trackEvent(event: Event.saveAvatarSuccess(avatar: avatar))
                
                router.dismissScreen()
            } catch {
                router.showAlert(error: error)
                interactor.trackEvent(event: Event.saveAvatarFail(error: error))
            }
            
            isSaving = false
        }
    }
    
    func onBackButtonPressed() {
        interactor.trackEvent(event: Event.backButtonPressed)
        router.dismissScreen()
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

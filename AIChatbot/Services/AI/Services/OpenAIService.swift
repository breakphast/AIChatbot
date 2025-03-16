//
//  OpenAIService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/4/25.
//

import SwiftUI
import IdentifiableByString
import FirebaseFunctions

struct OpenAIService: AIService {
    func generateImage(input: String) async throws -> UIImage {
        let response = try await Functions.functions().httpsCallable("generateOpenAIImage").call([
            "input": input
        ])
        
        guard
            let b64Json = response.data as? String,
            let data = Data(base64Encoded: b64Json),
            let image = UIImage(data: data) else {
            throw OpenAIError.invalidResponse
        }
        
        return image
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        let messages = chats.compactMap { chat in
            let role = chat.role.rawValue
            let content = chat.message
            return [
                "role": role,
                "content": content
            ]
        }
        
        let response = try await Functions.functions().httpsCallable("generateOpenAIText").call([
            "messages": messages
        ])
        
        let dict = response.data as? [String: Any]
        
        guard
            let dict = response.data as? [String: Any],
            let roleString = dict["role"] as? String,
            let role = AIChatRole(rawValue: roleString),
            let content = dict["content"] as? String else {
            throw OpenAIError.invalidResponse
        }
        
        return AIChatModel(role: role, content: content)
    }
    
    enum OpenAIError: LocalizedError {
        case invalidResponse
    }
}

struct AIChatModel: Codable {
    let role: AIChatRole
    let message: String
    
    init(role: AIChatRole, content: String) {
        self.role = role
        self.message = content
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "aiChat_\(CodingKeys.role.rawValue)": role.rawValue,
            "aiChat_\(CodingKeys.message.rawValue)": message
        ]
        
        return dict.compactMapValues { $0 }
    }
    
    enum CodingKeys: String, CodingKey {
        case role
        case message
    }
 }

enum AIChatRole: String, Codable {
    case system, user, assistant, tool
}

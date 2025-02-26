//
//  ChatBubbleView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/25/25.
//

import SwiftUI

struct ChatBubbleView: View {
    var text: String = "This is a sample text."
    var textColor: Color = .primary
    var backgroundColor: Color = Color(uiColor: .systemGray6)
    var imageName: String?
    var showImage: Bool = true
    let offset: CGFloat = 7
    var onProfileImagePressed: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if showImage {
                ZStack {
                    if let imageName {
                        ImageLoaderView(urlString: imageName)
                            .anyButton {
                                onProfileImagePressed?()
                            }
                    } else {
                        Rectangle()
                            .fill(.secondary)
                    }
                }
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                .offset(y: offset)
            }
            
            Text(text)
                .foregroundStyle(textColor)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(backgroundColor)
                .cornerRadius(6)
        }
        .padding(.bottom, showImage ? offset : 0)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ChatBubbleView()
            ChatBubbleView(text: "This is a chat bubble that has a lot of text that wraps multiple lines and keeps going. This is a chat bubble that has a lot of text that wraps multiple lines and keeps going")
            ChatBubbleView()
            
            ChatBubbleView(text: "This is a chat bubble that has a lot of text that wraps multiple lines and keeps going. This is a chat bubble that has a lot of text that wraps multiple lines and keeps going")
            ChatBubbleView(
                textColor: .white,
                backgroundColor: .accent,
                imageName: nil,
                showImage: false
            )
            ChatBubbleView(
                text: "This is a chat bubble that has a lot of text that wraps multiple lines and keeps going. This is a chat bubble that has a lot of text that wraps multiple lines and keeps going",
                textColor: .white,
                backgroundColor: .accent,
                imageName: nil
            )
        }
        .padding(8)
    }
}

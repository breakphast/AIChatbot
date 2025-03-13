//
//  CustomModalView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/13/25.
//

import SwiftUI

struct CustomModalView: View {
    var title = "Title"
    var subtitle: String? = "This is a subtitle."
    var primaryButtonTitle = "Yes"
    var primaryButtonAction: () -> Void = { }
    var secondaryButtonTitle = "No"
    var secondaryButtonAction: () -> Void = { }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
            
            VStack(spacing: 8) {
                Text(primaryButtonTitle)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.accent)
                    .foregroundStyle(.white)
                    .cornerRadius(16)
                    .anyButton(.press) {
                        primaryButtonAction()
                    }
                
                Text(secondaryButtonTitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .tappableBackground()
                    .anyButton {
                        secondaryButtonAction()
                    }
            }
        }
        .multilineTextAlignment(.center)
        .padding(16)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .padding(40)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        CustomModalView(
            title: "Are you enjoying AIChat?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: {
                
            },
            secondaryButtonTitle: "No",
            secondaryButtonAction: {
                
            })
    }
}

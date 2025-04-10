//
//  CustomModalView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/13/25.
//

import SwiftUI

/*
 title: "Enable push notifications?",
 subtitle: "We'll send you reminders and updates!",
 primaryButtonTitle: "Enable",
 primaryButtonAction: {
     onEnablePressed()
 },
 secondaryButtonTitle: "Cancel",
 secondaryButtonAction: {
     onCancelPressed()
 }
 */

struct CustomModalDelegate {
    var title = "Title"
    var subtitle: String? = "This is a subtitle."
    var primaryButtonTitle = "Yes"
    var primaryButtonAction: () -> Void = { }
    var secondaryButtonTitle = "No"
    var secondaryButtonAction: () -> Void = { }
}

struct CustomModalView: View {
    let delegate: CustomModalDelegate
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text(delegate.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                if let subtitle = delegate.subtitle {
                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
            
            VStack(spacing: 8) {
                Text(delegate.primaryButtonTitle)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.accent)
                    .foregroundStyle(.white)
                    .cornerRadius(16)
                    .anyButton(.press) {
                        delegate.primaryButtonAction()
                    }
                
                Text(delegate.secondaryButtonTitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .tappableBackground()
                    .anyButton {
                        delegate.secondaryButtonAction()
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
            delegate: CustomModalDelegate(
                title: "Are you enjoying AIChat?",
                subtitle: "We'd love to hear your feedback!",
                primaryButtonTitle: "Yes",
                primaryButtonAction: {
                    
                },
                secondaryButtonTitle: "No",
                secondaryButtonAction: {
                    
                }
            )
        )
    }
}

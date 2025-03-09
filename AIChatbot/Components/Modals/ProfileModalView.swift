//
//  ProfileModalView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/25/25.
//

import SwiftUI

struct ProfileModalView: View {
    var imageName: String? = Constants.randomImage
    var title: String? = "Alpha"
    var subtitle: String? = "Alien"
    var headline: String? = "An alien in the park."
    var onXMarkPressed: () -> Void = { }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                if let imageName {
                    ImageLoaderView(
                        urlString: imageName,
                        forceTransitionAnimation: true
                    )
                    .aspectRatio(1, contentMode: .fit)
                }
                
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(Color.black.opacity(0.7))
                    .anyButton {
                        onXMarkPressed()
                    }
                    .padding(12)
                    .tappableBackground()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let title {
                    Text(title)
                        .font(.title)
                        .fontWeight(.semibold)
                }
                
                if let subtitle {
                    Text(subtitle)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                
                if let headline {
                    Text(headline)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(.thinMaterial)
        .cornerRadius(16)
    }
}

#Preview("Model with image") {
    ZStack {
        Color.gray.ignoresSafeArea()
        
        ProfileModalView()
            .padding(.horizontal, 40)
    }
}

#Preview("Model without image") {
    ZStack {
        Color.gray.ignoresSafeArea()
        
        ProfileModalView(imageName: nil)
            .padding(.horizontal, 40)
    }
}

//
//  HeroCellView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/21/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct HeroCellView: View {
    var title: String? = "This is some title"
    var subtitle: String? = "This is some subtitile that will go here."
    var imageName: String? = Constants.randomImage
    
    var body: some View {
        ZStack {
            if let imageName {
                ImageLoaderView(urlString: imageName)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.accent)
            }
        }
        .overlay(alignment: .bottomLeading, content: {
            VStack(alignment: .leading, spacing: 4) {
                if let title {
                    Text(title)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                }
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .lineLimit(2)
                        .minimumScaleFactor(0.3)
                }
            }
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .cellGradientForText()
        })
        .cornerRadius(16)
    }
}

#Preview {
    ScrollView {
        VStack {
            HeroCellView()
                .frame(width: 300, height: 200)
            HeroCellView(imageName: nil)
                .frame(width: 300, height: 200)
            HeroCellView()
                .frame(width: 300, height: 200)
        }
        .frame(maxWidth: .infinity)
    }
}

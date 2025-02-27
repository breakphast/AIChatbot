//
//  CategoryCellView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/21/25.
//

import SwiftUI

struct CategoryCellView: View {
    var title: String = "Aliens"
    var imageName: String = Constants.randomImage
    var font: Font = .title2
    var cornerRadius: CGFloat = 16
    
    var body: some View {
        ZStack {
            ImageLoaderView(urlString: imageName)
                .aspectRatio(1, contentMode: .fit)
        }
        .overlay(alignment: .bottomLeading, content: {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(font)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cellGradientForText()
            }
        })
        .cornerRadius(cornerRadius)
    }
}

#Preview {
    VStack {
        CategoryCellView()
            .frame(width: 150)
        CategoryCellView()
            .frame(width: 300)
    }
}

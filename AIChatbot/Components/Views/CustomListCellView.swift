//
//  CustomListCellView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/22/25.
//

import SwiftUI

struct CustomListCellView: View {
    var imageName: String = Constants.randomImage
    var title: String? = "Alpha"
    var subtitle: String? = "An alien that is smiling and riding a bike"
    
    var body: some View {
        HStack(spacing: 8) {
            ImageLoaderView(urlString: imageName)
                .aspectRatio(1, contentMode: .fit)
                .frame(height: 66)
                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 4) {
                if let title {
                    Text(title)
                        .font(.headline)
                }
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .padding(.vertical, 4)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        
        CustomListCellView()
    }
}

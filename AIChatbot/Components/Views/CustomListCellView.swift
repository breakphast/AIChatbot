//
//  CustomListCellView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/22/25.
//

import SwiftUI

struct CustomListCellDelegate {
    var imageName: String? = Constants.randomImage
    var title: String? = "Alpha"
    var subtitle: String? = "An alien that is smiling in the park."
}

struct CustomListCellView: View {
    @Environment(\.colorScheme) private var colorScheme
    var delegate: CustomListCellDelegate = CustomListCellDelegate()
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                if let imageName = delegate.imageName {
                    ImageLoaderView(urlString: imageName)
                } else {
                    Rectangle()
                        .fill(.secondary.opacity(0.5))
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(height: 60)
            .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 4) {
                if let title = delegate.title {
                    Text(title)
                        .font(.headline)
                }
                if let subtitle = delegate.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .padding(.vertical, 4)
        .background(colorScheme.backgroundPrimary)
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container))
    
    return ZStack {
        Color.gray.ignoresSafeArea()
        
        VStack {
            builder.customListCellView(delegate: CustomListCellDelegate())
            builder.customListCellView(delegate: CustomListCellDelegate(imageName: nil))
            builder.customListCellView(delegate: CustomListCellDelegate(title: nil))
            builder.customListCellView(delegate: CustomListCellDelegate(subtitle: nil))
        }
    }
}

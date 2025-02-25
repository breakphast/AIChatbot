//
//  AsyncCallToActionButton.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/25/25.
//

import SwiftUI

struct AsyncCallToActionButton: View {
    var isLoading: Bool = false
    let text: String
    var action: () -> Void
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text(text)
            }
        }
        .callToActionButton()
        .anyButton(.press, action: {
            action()
        })
        .disabled(isLoading)
    }
}

private struct PreviewView: View {
    @State private var isLoading = false
    
    var body: some View {
        AsyncCallToActionButton(
            isLoading: isLoading,
            text: "Finish") {
                isLoading = true
                
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    isLoading = false
                }
            }
    }
}

#Preview {
    PreviewView()
        .padding()
}

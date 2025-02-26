//
//  ModalSupportView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/25/25.
//

import SwiftUI

struct ModalSupportView<Content: View>: View {
    @Binding var showModal: Bool
    @ViewBuilder var content: Content
    
    var body: some View {
        ZStack {
            if showModal {
                Color.black.opacity(0.4).ignoresSafeArea()
                    .transition(.opacity.animation(.smooth))
                    .onTapGesture {
                        showModal = false
                    }
                    .zIndex(1)
                
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .zIndex(2)
            }
        }
        .zIndex(99)
        .animation(.bouncy, value: showModal)
    }
}

extension View {
    func showModal(showModal: Binding<Bool>, @ViewBuilder content: () -> some View) -> some View {
        self
            .overlay(
                ModalSupportView(showModal: showModal) {
                    content()
                }
            )
    }
}

private struct PreviewView: View {
    @State private var showModal = false
    
    var body: some View {
        ZStack {
            Button("Click Me") {
                showModal = true
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .showModal(showModal: $showModal) {
                RoundedRectangle(cornerRadius: 30)
                    .padding(40)
                    .padding(.vertical, 100)
                    .onTapGesture {
                        showModal = false
                    }
                    .transition(.move(edge: .top))
            }
        }
    }
}

#Preview {
    PreviewView()
}

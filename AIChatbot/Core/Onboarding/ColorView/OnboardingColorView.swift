//
//  OnboardingColorView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/18/25.
//

import SwiftUI

struct OnboardingColorView: View {
    @State private var selectedColor: Color?
    let profileColors: [Color] = [.red, .green, .indigo, .blue, .orange, .pink, .yellow, .purple, .cyan]
    
    var body: some View {
        ScrollView {
            colorGrid
                .padding(.horizontal)
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 16, content: {
            ZStack {
                if let selectedColor {
                    ctaButton(selectedColor: selectedColor)
                    .transition(AnyTransition.move(edge: .bottom))
                }
            }
            .padding(24)
            .background(Color(UIColor.systemBackground))
        })
        .animation(.bouncy, value: selectedColor)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingColorView")
    }
    
    private var colorGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
            alignment: .center,
            spacing: 16,
            pinnedViews: [.sectionHeaders]) {
                Section {
                    ForEach(profileColors, id: \.self) { color in
                        Circle()
                            .fill(.accent)
                            .overlay {
                                color
                                    .clipShape(Circle())
                                    .padding(selectedColor == color ? 10 : 0)
                            }
                            .onTapGesture {
                                selectedColor = color
                            }
                            .accessibilityIdentifier("ColorCircle")
                    }
                } header: {
                    Text("Select a profile color")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
            }
    }
    
    private func ctaButton(selectedColor: Color) -> some View {
        NavigationLink {
            OnboardingCompletedView(selectedColor: selectedColor)
        } label: {
            Text("Continue")
                .callToActionButton()
        }
        .accessibilityIdentifier("ContinueButton")
    }
}

#Preview {
    NavigationStack {
        OnboardingColorView()
    }
    .previewEnvironment()
}

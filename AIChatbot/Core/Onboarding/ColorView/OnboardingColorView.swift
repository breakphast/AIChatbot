//
//  OnboardingColorView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/18/25.
//

import SwiftUI

struct OnboardingColorView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingColorViewModel
    @Binding var path: [OnboardingPathOption]
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                colorGrid
                    .padding(.horizontal)
            }
            .safeAreaInset(edge: .bottom, alignment: .center, spacing: 16, content: {
                ZStack {
                    if let selectedColor = viewModel.selectedColor {
                        ctaButton(selectedColor: selectedColor)
                            .transition(AnyTransition.move(edge: .bottom))
                    }
                }
                .padding(24)
                .background(Color(UIColor.systemBackground))
            })
            .animation(.bouncy, value: viewModel.selectedColor)
            .toolbar(.hidden, for: .navigationBar)
            .screenAppearAnalytics(name: "OnboardingColorView")
            .navigationDestinationForOnboarding(path: $path)
        }
    }
    
    private var colorGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
            alignment: .center,
            spacing: 16,
            pinnedViews: [.sectionHeaders]) {
                Section {
                    ForEach(viewModel.profileColors, id: \.self) { color in
                        Circle()
                            .fill(.accent)
                            .overlay {
                                color
                                    .clipShape(Circle())
                                    .padding(viewModel.selectedColor == color ? 10 : 0)
                            }
                            .onTapGesture {
                                viewModel.onColorPressed(color: color)
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
        Text("Continue")
            .callToActionButton()
            .anyButton {
                viewModel.onContinueButtonPressed(path: $path)
            }
            .accessibilityIdentifier("ColorContinueButton")
    }
}

#Preview {
    NavigationStack {
        OnboardingColorView(viewModel: OnboardingColorViewModel(interactor: CoreInteractor(container: DevPreview.shared.container), selectedColor: .mint), path: .constant([]))
    }
    .previewEnvironment()
}

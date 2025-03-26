//
//  CreateAccountView.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 2/23/25.
//

import SwiftUI
import AuthenticationServices

struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: CreateAccountViewModel
    
    var title: String = "Create Account?"
    var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account."
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(subtitle)
                    .lineLimit(4)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            SignInWithAppleButtonView(
                type: .signUp,
                style: .black,
                cornerRadius: 10
            )
            .frame(height: 55)
            .frame(maxWidth: 400)
            .anyButton(.press) {
                viewModel.onSignInApplePressed { isNewUser in
                    onDidSignIn?(isNewUser)
                    dismiss()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
        .screenAppearAnalytics(name: "CreateAccountView")
    }
}

#Preview {
    CreateAccountView(viewModel: CreateAccountViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvironment()
        .frame(maxHeight: 400)
        .frame(maxHeight: .infinity, alignment: .bottom)
}

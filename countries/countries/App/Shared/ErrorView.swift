//
//  ErrorView.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import SwiftUI

// MARK: - Reusable Error View
struct ErrorView: View {
    let message: String
    let retryAction: (() -> Void)?
    
    init(message: String, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let retryAction = retryAction {
                Button("Try Again", action: retryAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Error Alert
struct ErrorAlert: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let retryAction: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: $isPresented) {
                if let retryAction = retryAction {
                    Button("Try Again", action: retryAction)
                }
                Button("OK") { }
            } message: {
                Text(message)
            }
    }
}

// MARK: - View Extension
extension View {
    func errorAlert(
        isPresented: Binding<Bool>,
        message: String,
        retryAction: (() -> Void)? = nil
    ) -> some View {
        modifier(ErrorAlert(
            isPresented: isPresented,
            message: message,
            retryAction: retryAction
        ))
    }
}

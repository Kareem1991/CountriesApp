//
//  LoadingView.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import SwiftUI

struct LoadingView: View {
    let message: String
    
    init(_ message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Loading State View
struct LoadingStateView<T, Content: View>: View {
    let state: LoadingState<T>
    let loadingMessage: String
    let content: (T) -> Content
    
    init(
        state: LoadingState<T>,
        loadingMessage: String = "Loading...",
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.state = state
        self.loadingMessage = loadingMessage
        self.content = content
    }
    
    var body: some View {
        switch state {
        case .idle, .loading:
            LoadingView(loadingMessage)
        case .loaded(let data):
            content(data)
        case .error(let message):
            ErrorView(message: message)
        }
    }
}


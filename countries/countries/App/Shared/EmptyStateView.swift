//
//  EmptyStateView.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import SwiftUI
var emptyStateView: some View {
    Section {
        VStack {
            Image(systemName: "globe")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No countries added yet")
                .font(.headline)
            Text("Search and add up to 5 countries to get started")
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

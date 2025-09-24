//
//  CountryRow.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import SwiftUI

struct CountryRow: View {
    let country: Country
    let showAddButton: Bool
    let onTap: () -> Void
    let onAdd: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(country.name)
                    .font(.headline)
                Text("Capital: \(country.capital)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if showAddButton {
                Button("Add", action: onAdd)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

//
//  CountryDetailView.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import SwiftUI

struct CountryDetailView: View {
    let country: Country
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Country Name
                Text(country.name)
                    .font(.largeTitle)
                    .bold()
                
                // Details
                VStack(alignment: .leading, spacing: 12) {
                    DetailRow(title: "Capital", value: country.capital)
                    DetailRow(title: "Currency", value: country.currencyInfo)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Country Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}


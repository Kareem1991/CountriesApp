//
//  CountriesView.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import SwiftUI

struct CountriesView: View {
    @ObservedObject var viewModel: CountriesViewModel
    @State private var selectedCountry: Country?
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                searchBar
                
                LoadingStateView(
                    state: viewModel.state,
                    loadingMessage: "Loading countries..."
                ) { countries in
                    mainContent
                }
            }
            .navigationTitle("Countries")
            .errorAlert(
                isPresented: $viewModel.showError,
                message: viewModel.errorMessage,
                retryAction: viewModel.retry
            )
            .sheet(item: $selectedCountry) { country in
                CountryDetailView(country: country)
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            TextField("Search countries...", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !viewModel.searchText.isEmpty {
                Button("Clear") {
                    viewModel.clearSearch()
                }
            }
        }
        .padding()
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        List {
            // Selected Countries Section
            if !viewModel.selectedCountries.isEmpty {
                Section("My Countries (\(viewModel.selectedCountries.count)/5)") {
                    ForEach(viewModel.selectedCountries) { country in
                        CountryRow(country: country, showAddButton: false) {
                            selectedCountry = country
                        } onAdd: { }
                            .swipeActions(edge: .trailing) {
                                Button("Remove", role: .destructive) {
                                    viewModel.removeCountry(country)
                                }
                            }
                    }
                }
            }
            
            // Search Results Section
            if viewModel.showSearchResults {
                Section("Search Results") {
                    ForEach(viewModel.searchResults) { country in
                        CountryRow(
                            country: country,
                            showAddButton: viewModel.canAddMoreCountries && !viewModel.selectedCountries.contains(where: { $0.id == country.id })
                        ) {
                            selectedCountry = country
                        } onAdd: {
                            viewModel.addCountry(country)
                        }
                    }
                }
            } else if viewModel.selectedCountries.isEmpty {
                emptyStateView
            }
        }
    }
    
}


// MARK: - Preview
struct CountriesView_Previews: PreviewProvider {
    static var previews: some View {
        CountriesConfigurator.configureModule()
    }
}

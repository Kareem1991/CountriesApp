//
//  CountriesConfigurator.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import SwiftUI

@MainActor
final class CountriesConfigurator {
    static func configureModule() -> CountriesView {
        // Create services
        let repository = CountriesRemoteRepository()
        let useCase = CountriesUseCase(remoteCountriesRepo: repository)
        let locationService = LocationService()
        let storageService = StorageService()
        let searchService = SearchService()
        let countryService = CountryService()
        
        // Create view model with dependency injection
        let viewModel = CountriesViewModel(
            useCase: useCase,
            locationService: locationService,
            storageService: storageService,
            searchService: searchService,
            countryService: countryService
        )
        
        return CountriesView(viewModel: viewModel)
    }
}

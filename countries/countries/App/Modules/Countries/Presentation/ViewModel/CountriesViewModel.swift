//
//  CountriesViewModel.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Models
struct Country: Identifiable, Equatable, Codable {
    let id = UUID()
    let name: String
    let capital: String
    let currencyInfo: String
    let currencyCodes: [String]
    
    init(from response: Countries) {
        self.name = response.countryName
        self.capital = response.primaryCapital
        self.currencyInfo = response.currencyInfo
        self.currencyCodes = response.currencyCodes
    }
}

// MARK: - ViewModel
@MainActor
class CountriesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var state: LoadingState<[Country]> = .idle
    @Published var searchText: String = ""
    @Published var selectedCountries: [Country] = []
    @Published var searchResults: [Country] = []
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: - Private Properties
    private let useCase: CountriesUseCaseProtocol
    private let locationService: LocationServiceProtocol
    private let storageService: StorageServiceProtocol
    private let searchService: SearchServiceProtocol
    private let countryService: CountryServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var allCountries: [Country] = []
    
    // MARK: - Constants
    private enum Constants {
        static let maxCountries = 5
        static let defaultCountry = "United States"
    }
    
    // MARK: - Computed Properties
    var canAddMoreCountries: Bool {
        selectedCountries.count < Constants.maxCountries
    }
    
    var showSearchResults: Bool {
        !searchText.isEmpty && !searchResults.isEmpty
    }
    
    // MARK: - Initialization
    init(
        useCase: CountriesUseCaseProtocol,
        locationService: LocationServiceProtocol,
        storageService: StorageServiceProtocol,
        searchService: SearchServiceProtocol,
        countryService: CountryServiceProtocol
    ) {
        self.useCase = useCase
        self.locationService = locationService
        self.storageService = storageService
        self.searchService = searchService
        self.countryService = countryService
        
        setupSearch()
        loadCountries()
    }
    
    // MARK: - Public Methods
    func loadCountries() {
        state = .loading
        
        useCase.getCountries(fields: ["name", "capital", "currencies"])
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error.errorMessage)
                    }
                },
                receiveValue: { [weak self] countries in
                    self?.handleCountriesResponse(countries)
                }
            )
            .store(in: &cancellables)
    }
    
    func addCountry(_ country: Country) {
        let validation = countryService.validateCountryAddition(
            country,
            to: selectedCountries,
            maxCount: Constants.maxCountries
        )
        
        switch validation {
        case .valid:
            selectedCountries.append(country)
            saveSelectedCountries()
            clearSearch()
        case .maxLimitReached:
            showError("Maximum \(Constants.maxCountries) countries allowed")
        case .alreadyExists:
            showError("\(country.name) is already added")
        }
    }
    
    func removeCountry(_ country: Country) {
        selectedCountries.removeAll { $0.id == country.id }
        saveSelectedCountries()
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
    }
    
    func retry() {
        loadCountries()
    }
    
    // MARK: - Private Methods
    private func setupSearch() {
        let allCountriesPublisher = $state
            .compactMap { state in
                if case .loaded(let countries) = state {
                    return countries
                }
                return nil
            }
            .eraseToAnyPublisher()
        
        let searchQueryPublisher = $searchText
            .eraseToAnyPublisher()
        
        searchService.createSearchPublisher(
            for: allCountriesPublisher,
            with: searchQueryPublisher
        )
        .assign(to: &$searchResults)
    }
    
    private func handleCountriesResponse(_ response: [Countries]) {
        allCountries = response.map { Country(from: $0) }
        state = .loaded(allCountries)
        loadSelectedCountries()
        
        if selectedCountries.isEmpty {
            requestLocationPermission()
        }
    }
    
    private func handleError(_ message: String) {
        state = .error(message)
        showError(message)
        loadSelectedCountries()
    }
    
    private func requestLocationPermission() {
        locationService.requestLocationPermission()
        
        locationService.locationPublisher
            .compactMap { $0 }
            .flatMap { [weak self] location in
                self?.locationService.getCountryFromLocation(location) ?? Just(nil).eraseToAnyPublisher()
            }
            .sink { [weak self] countryName in
                self?.handleLocationResult(countryName)
            }
            .store(in: &cancellables)
    }
    
    private func handleLocationResult(_ countryName: String?) {
        if let countryName = countryName,
           let country = countryService.findCountryByLocation(countryName, in: allCountries) {
            addCountry(country)
        } else {
            addDefaultCountry()
        }
    }
    
    private func addDefaultCountry() {
        guard let defaultCountry = countryService.findCountry(by: Constants.defaultCountry, in: allCountries) else {
            return
        }
        
        if !selectedCountries.contains(where: { $0.id == defaultCountry.id }) {
            addCountry(defaultCountry)
        }
    }
    
    private func saveSelectedCountries() {
        _ = storageService.save(selectedCountries, forKey: StorageKeys.selectedCountries)
    }
    
    private func loadSelectedCountries() {
        if let countries = storageService.load([Country].self, forKey: StorageKeys.selectedCountries) {
            selectedCountries = countries
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showError = true
    }
}

//
//  countriesTests.swift
//  countriesTests
//
//  Created by Kareem on 24/09/2025.
//

import Testing
import Combine
import Foundation
@testable import countries

// MARK: - Test Helpers

extension Countries {
    static func mockCountry(
        name: String,
        capital: String? = nil,
        currencyCode: String? = nil,
        currencyName: String? = nil,
        currencySymbol: String? = nil
    ) -> Countries {
        var currencies: [String: Currency]?
        if let code = currencyCode, let name = currencyName {
            currencies = [code: Currency(name: name, symbol: currencySymbol)]
        }
        
        return Countries(
            name: Name(common: name, official: "Official \(name)"),
            capital: capital != nil ? [capital!] : nil,
            currencies: currencies,
            flags: Flags(svg: nil, png: nil),
            independent: true
        )
    }
}

// MARK: - Mock Repository for Testing

class MockCountriesRemoteRepository: CountriesRemoteRepositoryProtocol {
    var shouldFail = false
    var mockCountries: [Countries] = []
    var getCountriesCalled = false
    var fieldsReceived: [String] = []
    var errorToThrow: NetworkError = .serverError("Test error")
    
    func getCountries(fields: [String]) -> AnyPublisher<[Countries], NetworkError> {
        getCountriesCalled = true
        fieldsReceived = fields
        
        if shouldFail {
            return Fail(error: errorToThrow)
                .eraseToAnyPublisher()
        }
        
        return Just(mockCountries)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - Countries Model Tests

struct CountriesModelTests {
    
    @Test("Country name returns common name")
    func testCountryName() {
        // Given
        let country = Countries.mockCountry(name: "United States")
        
        // Then
        #expect(country.countryName == "United States")
    }
    
    @Test("Primary capital with value")
    func testPrimaryCapitalWithValue() {
        // Given
        let country = Countries.mockCountry(
            name: "USA",
            capital: "Washington D.C."
        )
        
        // Then
        #expect(country.primaryCapital == "Washington D.C.")
    }
    
    @Test("Primary capital without value")
    func testPrimaryCapitalWithoutValue() {
        // Given
        let country = Countries.mockCountry(name: "Antarctica")
        
        // Then
        #expect(country.primaryCapital == "No capital")
    }
    
    @Test("Currency info with symbol")
    func testCurrencyInfoWithSymbol() {
        // Given
        let country = Countries.mockCountry(
            name: "USA",
            currencyCode: "USD",
            currencyName: "US Dollar",
            currencySymbol: "$"
        )
        
        // Then
        #expect(country.currencyInfo == "US Dollar ($)")
    }
    
    @Test("Currency info without symbol")
    func testCurrencyInfoWithoutSymbol() {
        // Given
        let country = Countries.mockCountry(
            name: "Japan",
            currencyCode: "JPY",
            currencyName: "Japanese Yen"
        )
        
        // Then
        #expect(country.currencyInfo == "Japanese Yen")
    }
    
    @Test("Currency info without currencies")
    func testCurrencyInfoNoCurrency() {
        // Given
        let country = Countries.mockCountry(name: "Antarctica")
        
        // Then
        #expect(country.currencyInfo == "No currency information")
    }
    
    @Test("Currency codes extraction")
    func testCurrencyCodes() {
        // Given
        let countryWithCurrency = Countries.mockCountry(
            name: "USA",
            currencyCode: "USD",
            currencyName: "US Dollar"
        )
        let countryWithoutCurrency = Countries.mockCountry(name: "Antarctica")
        
        // Then
        #expect(countryWithCurrency.currencyCodes == ["USD"])
        #expect(countryWithoutCurrency.currencyCodes.isEmpty)
    }
    
    @Test("Multiple currencies handling")
    func testMultipleCurrencies() {
        // Given
        let currencies = [
            "EUR": Currency(name: "Euro", symbol: "€"),
            "USD": Currency(name: "US Dollar", symbol: "$")
        ]
        
        let country = Countries(
            name: Name(common: "Zimbabwe", official: "Republic of Zimbabwe"),
            capital: ["Harare"],
            currencies: currencies,
            flags: nil,
            independent: true
        )
        
        // Then
        #expect(country.currencyCodes.count == 2)
        #expect(country.currencyCodes.contains("EUR"))
        #expect(country.currencyCodes.contains("USD"))
        #expect(country.currencyInfo.contains("Euro (€)") || country.currencyInfo.contains("US Dollar ($)"))
    }
}

// MARK: - Country View Model Tests

struct CountryViewModelTests {
    
    @Test("Country initialization from Countries model")
    func testCountryInitialization() {
        // Given
        let countriesModel = Countries.mockCountry(
            name: "Canada",
            capital: "Ottawa",
            currencyCode: "CAD",
            currencyName: "Canadian Dollar",
            currencySymbol: "$"
        )
        
        // When
        let country = Country(from: countriesModel)
        
        // Then
        #expect(country.name == "Canada")
        #expect(country.capital == "Ottawa")
        #expect(country.currencyInfo == "Canadian Dollar ($)")
        #expect(country.currencyCodes == ["CAD"])
    }
    
    @Test("Country has unique ID")
    func testCountryUniqueID() {
        // Given
        let countriesModel = Countries.mockCountry(name: "France", capital: "Paris")
        
        // When
        let country1 = Country(from: countriesModel)
        let country2 = Country(from: countriesModel)
        
        // Then
        #expect(country1.id != country2.id)
    }
    
    @Test("Country equatable based on ID")
    func testCountryEquatable() {
        // Given
        let countriesModel1 = Countries.mockCountry(name: "Germany", capital: "Berlin")
        let countriesModel2 = Countries.mockCountry(name: "Spain", capital: "Madrid")
        
        // When
        let country1 = Country(from: countriesModel1)
        let country2 = Country(from: countriesModel2)
        let country1Copy = country1 // Same instance, same ID
        
        // Then
        #expect(country1 == country1Copy) // Same ID
        #expect(country1 != country2) // Different IDs
    }
    
    @Test("Country codable implementation")
    func testCountryCodable() throws {
        // Given
        let countriesModel = Countries.mockCountry(
            name: "Japan",
            capital: "Tokyo",
            currencyCode: "JPY",
            currencyName: "Japanese Yen",
            currencySymbol: "¥"
        )
        let country = Country(from: countriesModel)
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(country)
        
        let decoder = JSONDecoder()
        let decodedCountry = try decoder.decode(Country.self, from: data)
        
        // Then
        #expect(decodedCountry.name == country.name)
        #expect(decodedCountry.capital == country.capital)
        #expect(decodedCountry.currencyInfo == country.currencyInfo)
        #expect(decodedCountry.currencyCodes == country.currencyCodes)
    }
}

// MARK: - CountriesUseCase Tests

struct CountriesUseCaseTests {
    
    @Test("UseCase successfully returns countries from repository")
    func testGetCountriesSuccess() async throws {
        // Given
        let mockRepository = MockCountriesRemoteRepository()
        let useCase = CountriesUseCase(remoteCountriesRepo: mockRepository)
        
        mockRepository.mockCountries = [
            Countries.mockCountry(name: "USA", capital: "Washington"),
            Countries.mockCountry(name: "Canada", capital: "Ottawa")
        ]
        
        let fields = ["name", "capital", "currencies"]
        var cancellables = Set<AnyCancellable>()
        
        // When
        let result = await withCheckedContinuation { continuation in
            useCase.getCountries(fields: fields)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { countries in
                        continuation.resume(returning: countries)
                    }
                )
                .store(in: &cancellables)
        }
        
        // Then
        #expect(result.count == 2)
        #expect(result[0].countryName == "USA")
        #expect(result[1].countryName == "Canada")
        #expect(mockRepository.getCountriesCalled == true)
        #expect(mockRepository.fieldsReceived == fields)
    }
    
    @Test("UseCase handles repository failure")
    func testGetCountriesFailure() async throws {
        // Given
        let mockRepository = MockCountriesRemoteRepository()
        let useCase = CountriesUseCase(remoteCountriesRepo: mockRepository)
        
        mockRepository.shouldFail = true
        mockRepository.errorToThrow = .serverError("Network failure")
        
        var cancellables = Set<AnyCancellable>()
        var receivedError: NetworkError?
        
        // When
        await withCheckedContinuation { continuation in
            useCase.getCountries(fields: ["name"])
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            receivedError = error
                            continuation.resume()
                        }
                    },
                    receiveValue: { _ in }
                )
                .store(in: &cancellables)
        }
        
        // Then
        #expect(receivedError != nil)
        #expect(receivedError?.errorMessage == "Network failure")
    }
    
    @Test("UseCase passes correct fields to repository")
    func testUseCasePassesFieldsCorrectly() async throws {
        // Given
        let mockRepository = MockCountriesRemoteRepository()
        let useCase = CountriesUseCase(remoteCountriesRepo: mockRepository)
        mockRepository.mockCountries = []
        
        let expectedFields = ["name", "capital", "currencies", "flags", "independent"]
        var cancellables = Set<AnyCancellable>()
        
        // When
        _ = await withCheckedContinuation { continuation in
            useCase.getCountries(fields: expectedFields)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { _ in
                        continuation.resume()
                    }
                )
                .store(in: &cancellables)
        }
        
        // Then
        #expect(mockRepository.fieldsReceived == expectedFields)
    }
}

// MARK: - CountriesEndpointsProvider Tests

struct CountriesEndpointsProviderTests {
    
    @Test("Endpoint configuration for getting all countries")
    func testGetAllCountriesEndpoint() {
        // Given
        let fields = ["name", "capital", "currencies"]
        let endpoint = CountriesEndpointsProvider.getCountries(fields: fields)
        
        // Then
        #expect(endpoint.endPoint == "/all")
        #expect(endpoint.method == .GET)
    }
    
    @Test("Query parameters with fields")
    func testQueryParametersWithFields() {
        // Given
        let fields = ["name", "capital", "currencies"]
        let endpoint = CountriesEndpointsProvider.getCountries(fields: fields)
        
        // Then
        if let queryParams = endpoint.queryParams,
           let fieldsParam = queryParams["fields"] as? String {
            #expect(fieldsParam == "name,capital,currencies")
        } else {
            Issue.record("Query params should contain fields")
        }
    }
    
    @Test("Query parameters with single field")
    func testQueryParametersWithSingleField() {
        // Given
        let fields = ["name"]
        let endpoint = CountriesEndpointsProvider.getCountries(fields: fields)
        
        // Then
        if let queryParams = endpoint.queryParams,
           let fieldsParam = queryParams["fields"] as? String {
            #expect(fieldsParam == "name")
        } else {
            Issue.record("Query params should contain fields")
        }
    }
    
    @Test("Query parameters with empty fields")
    func testQueryParametersWithEmptyFields() {
        // Given
        let endpoint = CountriesEndpointsProvider.getCountries(fields: [])
        
        // Then
        if let queryParams = endpoint.queryParams,
           let fieldsParam = queryParams["fields"] as? String {
            #expect(fieldsParam == "")
        }
    }
}

// MARK: - Edge Cases Tests

struct CountriesEdgeCaseTests {
    
    @Test("Handle special characters in country names")
    func testSpecialCharactersInNames() {
        // Given
        let country = Countries.mockCountry(
            name: "Côte d'Ivoire",
            capital: "Yamoussoukro"
        )
        
        // Then
        #expect(country.countryName == "Côte d'Ivoire")
        #expect(country.primaryCapital == "Yamoussoukro")
    }
    
    @Test("Handle country with multiple capitals")
    func testMultipleCapitals() {
        // Given - Creating a country with multiple capitals manually
        let country = Countries(
            name: Name(common: "South Africa", official: "Republic of South Africa"),
            capital: ["Pretoria", "Cape Town", "Bloemfontein"],
            currencies: nil,
            flags: nil,
            independent: true
        )
        
        // Then - Should return the first capital
        #expect(country.primaryCapital == "Pretoria")
    }
    
    @Test("Handle empty country data")
    func testEmptyCountryData() {
        // Given
        let country = Countries(
            name: Name(common: "Unknown", official: nil),
            capital: nil,
            currencies: nil,
            flags: nil,
            independent: nil
        )
        
        // Then
        #expect(country.countryName == "Unknown")
        #expect(country.primaryCapital == "No capital")
        #expect(country.currencyInfo == "No currency information")
        #expect(country.currencyCodes.isEmpty)
    }
    
    @Test("Handle empty capitals array")
    func testEmptyCapitalsArray() {
        // Given
        let country = Countries(
            name: Name(common: "Test Country", official: "Official Test"),
            capital: [],  // Empty array instead of nil
            currencies: nil,
            flags: nil,
            independent: true
        )
        
        // Then
        #expect(country.primaryCapital == "No capital")
    }
    
    @Test("Handle very long country names")
    func testVeryLongCountryName() {
        // Given
        let longName = "The United Kingdom of Great Britain and Northern Ireland"
        let country = Countries.mockCountry(name: longName)
        
        // Then
        #expect(country.countryName == longName)
    }
}

// MARK: - Name and Currency Model Tests

struct NameAndCurrencyModelTests {
    
    @Test("Name model with official name")
    func testNameWithOfficialName() {
        // Given
        let name = Name(common: "USA", official: "United States of America")
        
        // Then
        #expect(name.common == "USA")
        #expect(name.official == "United States of America")
    }
    
    @Test("Name model without official name")
    func testNameWithoutOfficialName() {
        // Given
        let name = Name(common: "Unknown", official: nil)
        
        // Then
        #expect(name.common == "Unknown")
        #expect(name.official == nil)
    }
    
    @Test("Currency model with symbol")
    func testCurrencyWithSymbol() {
        // Given
        let currency = Currency(name: "Euro", symbol: "€")
        
        // Then
        #expect(currency.name == "Euro")
        #expect(currency.symbol == "€")
    }
    
    @Test("Currency model without symbol")
    func testCurrencyWithoutSymbol() {
        // Given
        let currency = Currency(name: "Some Currency", symbol: nil)
        
        // Then
        #expect(currency.name == "Some Currency")
        #expect(currency.symbol == nil)
    }
}

// MARK: - Flags Model Tests

struct FlagsModelTests {
    
    @Test("Flags with both SVG and PNG")
    func testFlagsWithBothFormats() {
        // Given
        let flags = Flags(
            svg: "https://example.com/flag.svg",
            png: "https://example.com/flag.png"
        )
        
        // Then
        #expect(flags.svg == "https://example.com/flag.svg")
        #expect(flags.png == "https://example.com/flag.png")
    }
    
    @Test("Flags with only SVG")
    func testFlagsWithOnlySVG() {
        // Given
        let flags = Flags(
            svg: "https://example.com/flag.svg",
            png: nil
        )
        
        // Then
        #expect(flags.svg == "https://example.com/flag.svg")
        #expect(flags.png == nil)
    }
    
    @Test("Flags with no URLs")
    func testFlagsWithNoURLs() {
        // Given
        let flags = Flags(svg: nil, png: nil)
        
        // Then
        #expect(flags.svg == nil)
        #expect(flags.png == nil)
    }
}

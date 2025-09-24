//
//  CountryService.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import Foundation
import Combine

protocol CountryServiceProtocol: AnyObject {
    func findCountry(by name: String, in countries: [Country]) -> Country?
    func findCountryByLocation(_ locationName: String, in countries: [Country]) -> Country?
    func validateCountryAddition(_ country: Country, to selectedCountries: [Country], maxCount: Int) -> ValidationResult
}

enum ValidationResult {
    case valid
    case maxLimitReached
    case alreadyExists
}

class CountryService: CountryServiceProtocol {

    func findCountry(by name: String, in countries: [Country]) -> Country? {
        return countries.first { country in
            country.name.lowercased().contains(name.lowercased())
        }
    }
    
    func findCountryByLocation(_ locationName: String, in countries: [Country]) -> Country? {
        return countries.first { country in
            country.name.lowercased().contains(locationName.lowercased())
        }
    }
    
    func validateCountryAddition(_ country: Country, to selectedCountries: [Country], maxCount: Int) -> ValidationResult {
        if selectedCountries.count >= maxCount {
            return .maxLimitReached
        }
        
        if selectedCountries.contains(where: { $0.id == country.id }) {
            return .alreadyExists
        }
        
        return .valid
    }
}

extension Country: Searchable {
    var searchableText: String {
        return "\(name) \(capital) \(currencyInfo) \(currencyCodes.joined(separator: " "))"
    }
}

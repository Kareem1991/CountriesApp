//
//  CountriesResponseModel.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import Foundation

struct Countries: Codable {
    let name: Name
    let capital: [String]?
    let currencies: [String: Currency]?
    let flags: Flags?
    let independent: Bool?
    
    var primaryCapital: String {
        return capital?.first ?? "No capital"
    }
    
    var currencyInfo: String {
        guard let currencies = currencies, !currencies.isEmpty else {
            return "No currency information"
        }
        
        let currencyStrings = currencies.values.compactMap { currency in
            if let symbol = currency.symbol {
                return "\(currency.name) (\(symbol))"
            } else {
                return currency.name
            }
        }
        
        return currencyStrings.joined(separator: ", ")
    }
    
    var currencyCodes: [String] {
        return currencies?.keys.map { $0 } ?? []
    }
    
    var countryName: String {
        return name.common
    }
}

struct Name: Codable {
    let common: String
    let official: String?
}

struct Currency: Codable {
    let name: String
    let symbol: String?
}

struct Flags: Codable {
    let svg: String?
    let png: String?
}

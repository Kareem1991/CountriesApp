//
//  CountriesEndpointsProvider.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import Foundation

enum CountriesEndpointsProvider {
    case getCountries(fields: [String])
}

extension CountriesEndpointsProvider: NetworkRequest {
    var endPoint: String {
        switch self {
        case .getCountries:
            return "/all"
        }
    }
    
    var queryParams: [String: Any]? {
        switch self {
        case .getCountries(let fields):
            return ["fields": fields.joined(separator: ",")]
        }
    }
    
    var method: APIHTTPMethod {
        .GET
    }
}

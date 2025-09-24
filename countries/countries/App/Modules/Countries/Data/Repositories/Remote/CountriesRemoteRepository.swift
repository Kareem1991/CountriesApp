//
//  CountriesRemoteRepository.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import Foundation
import Combine

class CountriesRemoteRepository: CountriesRemoteRepositoryProtocol {
    let networkClient = NetworkClient()
    
    
    func getCountries(fields: [String]) -> AnyPublisher<[Countries], NetworkError> {
        networkClient.request(request: CountriesEndpointsProvider.getCountries(fields: fields).makeRequest)
    }
    
}

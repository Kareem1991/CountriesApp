//
//  CountriesUseCase.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import Foundation
import Combine

protocol CountriesUseCaseProtocol: AnyObject {
    func getCountries(fields:[String]) -> AnyPublisher<[Countries], NetworkError>

}

class CountriesUseCase: CountriesUseCaseProtocol {
    private let remoteCountriesRepo: CountriesRemoteRepositoryProtocol

    init(remoteCountriesRepo: CountriesRemoteRepositoryProtocol) {
        self.remoteCountriesRepo = remoteCountriesRepo
    }
    
    func getCountries(fields:[String]) -> AnyPublisher<[Countries], NetworkError> {
        return remoteCountriesRepo.getCountries(fields: fields)
    }
}

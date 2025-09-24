//
//  CountriesRepositoryInterfaces.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import Foundation
import Combine

protocol CountriesRemoteRepositoryProtocol: AnyObject {
    func getCountries(fields:[String]) -> AnyPublisher<[Countries], NetworkError>

}


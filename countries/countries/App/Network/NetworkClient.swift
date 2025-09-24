//
//  NetworkClient.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import Foundation
import Combine

protocol NetworkClientProtocol: AnyObject {
    func request<R: Codable>(request: URLRequest) -> AnyPublisher<R, NetworkError>
}

final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func request<R: Decodable>(request: URLRequest) -> AnyPublisher<R, NetworkError> {
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: R.self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return NetworkError.decodingError
                } else {
                    return NetworkError.requestFailed
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

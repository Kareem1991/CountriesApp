//
//  NetworkRequest.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import Foundation

protocol NetworkRequest {
    var baseURL: String { get }
    var endPoint: String { get }
    var headers: [String: String]? { get }
    var queryParams: [String: Any]? { get }
    var method: APIHTTPMethod { get }
}

enum APIConfig {
    static let baseURL = "https://restcountries.com/v3.1"
}

extension NetworkRequest {
    var baseURL: String {
        APIConfig.baseURL
    }
    
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}

extension NetworkRequest {
    var makeRequest: URLRequest {
        guard var urlComponents = URLComponents(string: baseURL) else {
            return URLRequest(url: URL(fileURLWithPath: ""))
        }
        
        urlComponents.path = "\(urlComponents.path)\(endPoint)"
        
        if let queryParams = queryParams {
            urlComponents.queryItems = queryParams.map { key, value in
                URLQueryItem(name: key, value: String(describing: value))
            }
        }
        
        guard let url = urlComponents.url else {
            return URLRequest(url: URL(fileURLWithPath: ""))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}

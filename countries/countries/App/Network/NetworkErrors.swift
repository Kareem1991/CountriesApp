//
//  NetworkErrors.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import Foundation

enum NetworkError: Error, Equatable {
    case requestFailed
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    
    var errorMessage: String {
        switch self {
        case .requestFailed:
            return "Request failed. Please check your connection."
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to process server response"
        case .serverError(let message):
            return message
        }
    }
}

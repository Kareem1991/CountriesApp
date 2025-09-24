//
//  LoadingState.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import Foundation

// MARK: - Generic Loading State
enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(String)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var isLoaded: Bool {
        if case .loaded = self { return true }
        return false
    }
    
    var isError: Bool {
        if case .error = self { return true }
        return false
    }
    
    var data: T? {
        if case .loaded(let data) = self { return data }
        return nil
    }
    
    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}

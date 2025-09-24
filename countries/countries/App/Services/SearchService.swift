//
//  SearchService.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import Foundation
import Combine

// MARK: - Searchable Protocol
protocol Searchable {
    var searchableText: String { get }
}

// MARK: - Search Service Protocol
protocol SearchServiceProtocol: AnyObject {
    func search<T: Searchable>(_ items: [T], with query: String) -> [T]
    func createSearchPublisher<T: Searchable>(
        for items: AnyPublisher<[T], Never>,
        with query: AnyPublisher<String, Never>
    ) -> AnyPublisher<[T], Never>
}

// MARK: - Search Service
class SearchService: SearchServiceProtocol {
    // MARK: - Constants
    private enum Constants {
        static let debounceTime: TimeInterval = 0.3
    }
    
    // MARK: - Public Methods
    func search<T: Searchable>(_ items: [T], with query: String) -> [T] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else { return [] }
        
        let lowercasedQuery = trimmedQuery.lowercased()
        
        return items.filter { item in
            item.searchableText.lowercased().contains(lowercasedQuery)
        }
    }
    
    func createSearchPublisher<T: Searchable>(
        for items: AnyPublisher<[T], Never>,
        with query: AnyPublisher<String, Never>
    ) -> AnyPublisher<[T], Never> {
        return Publishers.CombineLatest(items, query)
            .debounce(for: .seconds(Constants.debounceTime), scheduler: RunLoop.main)
            .map { [weak self] items, query in
                self?.search(items, with: query) ?? []
            }
            .eraseToAnyPublisher()
    }
}

//
//  StorageService.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import Foundation

// MARK: - Storage Service Protocol
protocol StorageServiceProtocol: AnyObject {
    func save<T: Codable>(_ object: T, forKey key: String) -> Bool
    func load<T: Codable>(_ type: T.Type, forKey key: String) -> T?
    func remove(forKey key: String)
    func clear()
}

// MARK: - Storage Service
class StorageService: StorageServiceProtocol {
    // MARK: - Private Properties
    private let userDefaults: UserDefaults
    
    // MARK: - Initialization
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Public Methods
    func save<T: Codable>(_ object: T, forKey key: String) -> Bool {
        do {
            let data = try JSONEncoder().encode(object)
            userDefaults.set(data, forKey: key)
            return true
        } catch {
            print("Failed to save \(T.self) for key \(key): \(error)")
            return false
        }
    }
    
    func load<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("Failed to load \(type) for key \(key): \(error)")
            return nil
        }
    }
    
    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    func clear() {
        let domain = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: domain)
    }
}

// MARK: - Storage Keys
enum StorageKeys {
    static let selectedCountries = "SelectedCountries"
    static let userPreferences = "UserPreferences"
}

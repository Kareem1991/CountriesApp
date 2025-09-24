//
//  LocationService.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import Foundation
import CoreLocation
import Combine

protocol LocationServiceProtocol {
    var locationPublisher: AnyPublisher<CLLocation?, Never> { get }
    var authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    
    func requestLocationPermission()
    func requestLocation()
    func getCountryFromLocation(_ location: CLLocation) -> AnyPublisher<String?, Never>
}

@MainActor
class LocationService: NSObject, LocationServiceProtocol {
    private let locationManager = CLLocationManager()
    private let locationSubject = PassthroughSubject<CLLocation?, Never>()
    private let authorizationSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    
    nonisolated var locationPublisher: AnyPublisher<CLLocation?, Never> {
        locationSubject.eraseToAnyPublisher()
    }
    
    nonisolated var authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        authorizationSubject.eraseToAnyPublisher()
    }
    
    nonisolated var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    nonisolated func requestLocationPermission() {
        Task { @MainActor in
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                break
            case .authorizedWhenInUse, .authorizedAlways:
                requestLocation()
            @unknown default:
                break
            }
        }
    }
    
    nonisolated func requestLocation() {
        Task { @MainActor in
            guard locationManager.authorizationStatus == .authorizedWhenInUse ||
                  locationManager.authorizationStatus == .authorizedAlways else {
                return
            }
            locationManager.requestLocation()
        }
    }
    
    nonisolated func getCountryFromLocation(_ location: CLLocation) -> AnyPublisher<String?, Never> {
        let geocoder = CLGeocoder()
        
        return Future<String?, Never> { promise in
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let placemark = placemarks?.first {
                    promise(.success(placemark.country))
                } else {
                    promise(.success(nil))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationSubject.send(locations.last)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationSubject.send(nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationSubject.send(status)
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            requestLocation()
        }
    }
}

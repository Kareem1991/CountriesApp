//
//  countriesApp.swift
//  countries
//
//  Created by Kareem on 24/09/2025.
//

import SwiftUI

@main
struct countriesApp: App {
    var body: some Scene {
        WindowGroup {
            CountriesConfigurator.configureModule()
        }
    }
}

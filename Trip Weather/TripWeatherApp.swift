//
//  Trip_WeatherApp.swift
//  Trip Weather
//
//  Created by Jonathan Liu on 30/8/21.
//

import SwiftUI

@main
struct Trip_WeatherApp: App {
    @ObservedObject var viewModel: TripsViewModel = TripsViewModel()

    var body: some Scene {
        WindowGroup {
            BaseView()
                .environmentObject(viewModel)
        }
    }
}

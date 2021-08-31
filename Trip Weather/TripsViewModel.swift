//
//  TripWeatherViewModel.swift
//  TripWeatherViewModel
//
//  Created by Jonathan Liu on 30/8/21.
//

import Foundation

class TripsViewModel: ObservableObject {
    @Published var model: TripWeatherModel = TripWeatherModel()
    
    typealias Trip = TripWeatherModel.STrip
    // MARK: Intents
}

//
//  TripWeatherViewModel.swift
//  TripWeatherViewModel
//
//  Created by Jonathan Liu on 30/8/21.
//

import Foundation
import SwiftUI

class TripsViewModel: ObservableObject {
    @Published var model: TripWeatherModel = TripWeatherModel()
    @State var tripToAdd = TripsViewModel.Trip(name: "", description: "", startDate: Date(), endDate: Date(), timestampAdded: Date(), locations: [], images: [], id: 0)
    
    typealias Trip = TripWeatherModel.STrip
    typealias Location = TripWeatherModel.SLocation
    
    
    // MARK: Intents
}

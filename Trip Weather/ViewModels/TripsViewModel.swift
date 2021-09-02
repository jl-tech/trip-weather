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
    @Published var tripToAdd = TripsViewModel.Trip(name: "", description: "", startDate: Date(), endDate: Date(), timestampAdded: Date(), locations: [], image: nil, id: 0)
    
    typealias Trip = TripWeatherModel.Trip
    typealias Location = TripWeatherModel.Location
    
    // MARK: Add Trip
    func resetToAdd() {
        tripToAdd = TripsViewModel.Trip(name: "", description: "", startDate: Date(), endDate: Date(), timestampAdded: Date(), locations: [], image: nil, id: 0)
    }
    
    func addLocation(day: Date, latitude: Double, longitude: Double, name: String) {
        let newLoc = Location(day: day, latitude: latitude, longitude: longitude, name: name, id: tripToAdd.locations.count)
        tripToAdd.locations.append(newLoc)
    }
    
    func nLocationsWithDate(_ date: Date) -> Int {
        var count: Int = 0
        for item in tripToAdd.locations {
            if item.day == date {
                count += 1
            }
        }
        return count
    }
    
    func locationsWithDate(_ date: Date) -> [Location] {
        var result: [Location] = []
        for item in tripToAdd.locations {
            if item.day == date {
                result.append(item)
            }
        }
        return result
    }
    
    func doCreateTrip() {
        model.addTrip(tripToAdd)
    }
    
    // MARK: Model data
    func trips() -> [Trip] {
        return model.trips
    }
    
    // MARK: Intents
}

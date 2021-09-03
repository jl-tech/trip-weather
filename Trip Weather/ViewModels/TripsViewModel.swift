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
    @Published var activeTrip = TripsViewModel.Trip(name: "", description: "", startDate: Date.stripTime(from: Date()), endDate: Date.stripTime(from: Date()), timestampAdded: Date(), locations: [], image: nil) // the trip being created or edited
    
    typealias Trip = TripWeatherModel.Trip
    typealias Location = TripWeatherModel.Location
    
    // MARK: Add/Edit Trip
    
    func setActiveTrip(id: UUID) {
        activeTrip = model.trips.first(where: { $0.id == id })!
    }
    
    func resetActiveTrip() {
        activeTrip = TripsViewModel.Trip(name: "", description: "", startDate: Date.stripTime(from: Date()), endDate: Date.stripTime(from: Date()), timestampAdded: Date(), locations: [], image: nil) 
    }
    
    func resetToAdd() {
        activeTrip = TripsViewModel.Trip(name: "", description: "", startDate: Date.stripTime(from: Date()), endDate: Date.stripTime(from: Date()), timestampAdded: Date(), locations: [], image: nil)
    }
    
    func addLocation(day: Date, latitude: Double, longitude: Double, name: String) {
        let newLoc = Location(day: day, latitude: latitude, longitude: longitude, name: name)
        activeTrip.locations.append(newLoc)
    }
    
    func nLocationsWithDate(_ date: Date) -> Int {
        var count: Int = 0
        for item in activeTrip.locations {
            if item.day == date {
                count += 1
            }
        }
        return count
    }
    
    func locationsWithDate(_ date: Date) -> [Location] {
        var result: [Location] = []
        for item in activeTrip.locations {
            if item.day == date {
                result.append(item)
            }
        }
        return result
    }
    
    func doCreateTrip() {
        model.addTrip(activeTrip)
    }
    
    func doEditTrip() {
        model.editTrip(activeTrip)
    }
    
    // MARK: Model data
    func trips() -> [Trip] {
        return model.trips
    }
    

    
    // MARK: Intents
    func loadTrips() {
        model.loadTrips()
    }
    
    func removeTrip(_ trip: Trip) {
        model.removeTrip(trip)
    }
}

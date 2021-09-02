//
//  TripWeatherModel.swift
//  TripWeatherModel
//
//  Created by Jonathan Liu on 30/8/21.
//

import Foundation
import CoreData
import SwiftUI

struct TripWeatherModel {
    @Environment(\.managedObjectContext) var context
    private (set) var trips: [Trip]
    
    struct Trip: Identifiable {
        var name: String
        var description: String
        var startDate: Date
        var endDate: Date
        var timestampAdded: Date
        var locations: [Location]
        var image: Data?
        var id: Int
        
    }
    
    struct Location: Identifiable {
        var day: Date
        var latitude: Double
        var longitude: Double
        var name: String
        var id: Int
    }
    
    init() {
        // Load from disk
        // TEMP
        trips = []
    }
    
    mutating func addTrip(_ trip: Trip) {
        var tripToAdd = trip
        tripToAdd.id = trips.count
        trips.append(tripToAdd)
        print(trips)
    }
    
    
}
 

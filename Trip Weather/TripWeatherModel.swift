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
    
    struct Trip: Identifiable, Codable {
        var name: String
        var description: String
        var startDate: Date
        var endDate: Date
        var timestampAdded: Date
        var locations: [Location]
        var image: Data?
        var id: Int
        
    }
    
    struct Location: Identifiable, Codable {
        var day: Date
        var latitude: Double
        var longitude: Double
        var name: String
        var id: Int
    }
    
    init() {
        trips = []
    }
    
    mutating func addTrip(_ trip: Trip) {
        var tripToAdd = trip
        tripToAdd.id = trips.count
        trips.append(tripToAdd)
        saveTrips()
    }
    
    // MARK: Persistence
    
    func jsonifyTrips() throws -> Data {
        return try JSONEncoder().encode(trips)
    }
    
    func saveTrips() {
        let manager = FileManager.default
        if let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let data: Data = try jsonifyTrips()
                try data.write(to: url.appendingPathComponent("trips.json"))
            } catch let error {
                print("ERROR!! \(String(describing: self)) - \(error)")
            }
        } else {
            print("ERROR!! \(String(describing: self)) - URL returned nil!")
        }
    }
    
    mutating func loadTrips() {
        let manager = FileManager.default
        if let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let data = try Data(contentsOf: url.appendingPathComponent("trips.json"))
                trips = try JSONDecoder().decode([Trip].self, from: data)
            } catch let error {
                print("ERROR!! \(String(describing: self)) - \(error)")
            }
        } else {
            print("ERROR!! \(String(describing: self)) - URL returned nil!")
        }
    }
    
}
 

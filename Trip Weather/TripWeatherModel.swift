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
        var id = UUID()
        
    }
    
    struct Location: Identifiable, Codable {
        var day: Date
        var latitude: Double
        var longitude: Double
        var name: String
        var id = UUID()
        var forecast: WeatherBitForecast?
    }
    
    init() {
        trips = []
    }
    
    // MARK: Functions
    mutating func addTrip(_ trip: Trip) {
        trips.append(trip)
        saveTrips()
    }
    
    mutating func editTrip(_ trip: Trip) {
        if let idx = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[idx] = trip
        }
        saveTrips()
    }
    
    mutating func removeTrip(_ trip: Trip) {
        trips.removeAll(where: { $0.id == trip.id })
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
    
    // MARK: Weather
    mutating func loadWeatherForTrip(id: UUID) {
        
    }
    
    private func getWeather(location: Location) {
        
    }
    
    struct WeatherBitForecast: Codable {
        // Does not contain all fields available by WeatherBit API, only those neccessary
        
        // Wind
        var wind_gust_spd: Double
        var wind_spd: Double
        var wind_dir: Int
        var wind_cdir: String
        
        // Temp
        var high_temp: Int
        var low_temp: Int
        var app_max_temp: Double // Feels like
        var app_min_temp: Double
        
        // Precip
        var snow: Int
        var precip: Int
        var pop: Int // Prob of precip
        var rh: Int // Humidity
        var clouds: Int
        
        // Conditions
        var weather: WeatherBitConditions
        var vis: Int
        var uv: Int
        
        // SUn
        var sunrise_ts: Date
        var sunset_ts: Date
        
    }
    
    struct WeatherBitConditions: Codable {
        var icon: String
        var code: String
        var descriptoin: String
    }
}
 

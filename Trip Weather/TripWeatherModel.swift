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
    
    mutating func loadWeatherForLocation(location: Location, tripIdx: Int) {
        let dateString = toWeatherKitDateString(from: location.day)
        
        if let url = URL(string: "https://api.weatherbit.io/v2.0/forecast/daily?lat=\(location.latitude)&lon=\(location.longitude)&key=\(APIKeys.weatherbitKey)") {
            let request = URLRequest(url: url)
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode(WeatherBitForecast.self, from: data)
                        let resultData = decodedResponse.data.filter( { $0.valid_date == dateString })
                        let result = WeatherBitForecast(data: resultData, city_name: decodedResponse.city_name)
                        DispatchQueue.main.async {
                            print(result)
                            if let idx = trips[tripIdx].locations.firstIndex(where: { $0.id == location.id }) {
                                var newLoc = trips[tripIdx].locations[idx]
                                newLoc.forecast = result
                            } else {
                                return
                            }
                            
                        }
                        
                    } catch {
                        print(error)
                    }
                    
                }
            }.resume()
        } else {
            print("ERROR!! \(String(describing: self)) - URL returned nil!")
            return
        }

        
    }
    
    struct WeatherBitForecast: Codable {
        var data: [WeatherBitForecastDay]
        var city_name: String
    }
    
    struct WeatherBitForecastDay: Codable {
        // Does not contain all fields available by WeatherBit API, only those neccessary
        var valid_date: String
        
        // Wind
        var wind_gust_spd: Double
        var wind_spd: Double
        var wind_dir: Int
        var wind_cdir: String
        
        // Temp
        var high_temp: Double
        var low_temp: Double
        var app_max_temp: Double // Feels like
        var app_min_temp: Double
        
        // Precip
        var snow: Double
        var precip: Double
        var pop: Double // Prob of precip
        var rh: Double // Humidity
        var clouds: Double
        
        // Conditions
        var weather: WeatherBitConditions
        var vis: Double
        var uv: Double
        
        // SUn
        var sunrise_ts: Date
        var sunset_ts: Date
        
    }
    
    struct WeatherBitConditions: Codable {
        var icon: String
        var code: Int
        var description: String
    }
}


//
//  TripWeatherModel.swift
//  TripWeatherModel
//
//  Created by Jonathan Liu on 30/8/21.
//

import Foundation
import CoreData
import SwiftUI

class TripWeatherModel {
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
        var weatherLoadStatus: WeatherLoadStatus
    }
    
    init() {
        trips = []
    }
    
    // MARK: Functions
    func addTrip(_ trip: Trip) {
        trips.append(trip)
        saveTrips()
    }
    
    func editTrip(_ trip: Trip) {
        if let idx = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[idx] = trip
        }
        saveTrips()
    }
    
    func removeTrip(_ trip: Trip) {
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
    
    func loadTrips() {
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
    func setLocationForecast(tripID: UUID, locationID: UUID, forecast: WeatherBitForecast?, status: WeatherLoadStatus) {
        if let tripIdx = trips.firstIndex(where: { $0.id == tripID }) {
            if let locationIdx = trips[tripIdx].locations.firstIndex(where: { $0.id == locationID }) {
                var newLoc = trips[tripIdx].locations[locationIdx]
                newLoc.weatherLoadStatus = status
                newLoc.forecast = forecast
                trips[tripIdx].locations[locationIdx] = newLoc
            }
        }
    }
    
    func loadWeatherForTrip(id: UUID) {
        
    }
    
    func loadWeatherForLocation(location: Location, tripId: UUID) {
        let dateString = toWeatherKitDateString(from: location.day)

        if let url = URL(string: "https://api.weatherbit.io/v2.0/forecast/daily?lat=\(location.latitude)&lon=\(location.longitude)&key=\(APIKeys.weatherbitKey)") {
            let request = URLRequest(url: url)
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode(WeatherBitForecast.self, from: data)
                        let resultData = decodedResponse.data.filter( { $0.valid_date == dateString })
                        let result = WeatherBitForecast(data: resultData, city_name: decodedResponse.city_name)
                        DispatchQueue.main.async { [self] in
                            print(result)
                            setLocationForecast(tripID: tripId, locationID: location.id, forecast: result, status: .loaded)
                        }
                    } catch {
                        print(error)
                        self.setLocationForecast(tripID: tripId, locationID: location.id, forecast: nil, status: .error)
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
    
    enum WeatherLoadStatus: Codable {
        case idle
        case loading
        case loaded
        case error
    }
}


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
    
    let apiQueue = DispatchQueue(label: "apiQueue")
    
    func tripIsInProgress(trip: Trip) -> Bool {
        return Date.isBetweenDates(check: Date.stripTime(from: Date()), startDate: trip.startDate, endDate: trip.endDate)
    }
    
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
        let newLoc = Location(day: day, latitude: latitude, longitude: longitude, name: name, weatherLoadStatus: .idle)
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
        objectWillChange.send()
        model.addTrip(activeTrip)
    }
    
    func doEditTrip() {
        objectWillChange.send()
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
    
    func loadWeatherForTrip(_ trip: Trip) {
        loadWeatherForTrip(id: trip.id)
    }
    
    // MARK: Loading Weather
    typealias WeatherBitForecast = TripWeatherModel.WeatherBitForecast
    typealias WeatherLoadStatus = TripWeatherModel.WeatherLoadStatus
    func setLocationForecast(tripID: UUID, locationID: UUID, forecast: WeatherBitForecast?, status: WeatherLoadStatus) {
        if let tripIdx = model.trips.firstIndex(where: { $0.id == tripID }) {
            if let locationIdx = model.trips[tripIdx].locations.firstIndex(where: { $0.id == locationID }) {
                var newLoc = model.trips[tripIdx].locations[locationIdx]
                newLoc.weatherLoadStatus = status
                newLoc.forecast = forecast
                model.modifyLocation(tripIdx: tripIdx, locIdx: locationIdx, newLoc: newLoc)
            }
        }
    }
    
    func loadWeatherForTrip(id: UUID) {
        if let trip = model.trips.first(where: { $0.id == id }) {
            for (idx, location) in trip.locations.enumerated() {
                loadWeatherForLocation(location: location, tripId: id, idx: Double(idx))
            }
        }
    }
    
    func loadWeatherForLocation(location: Location, tripId: UUID, idx: Double) {
        if location.day < Date.stripTime(from: Date()) {
            // get historical weather TODO
            setLocationForecast(tripID: tripId, locationID: location.id, forecast: nil, status: .unavailable)
            return
        }
        if location.day == Date.stripTime(from: Date()) {
            // get current conditions TODO
            
        }
        let dateString = toWeatherKitDateString(from: location.day)
        setLocationForecast(tripID: tripId, locationID: location.id, forecast: nil, status: .loading)
        var urlAddress = "https://api.weatherbit.io/v2.0/forecast/daily?lat=\(location.latitude)&lon=\(location.longitude)&key=\(APIKeys.weatherbitKey)"
        if UserDefaults.standard.bool(forKey: "isUsingImperial") {
            urlAddress += "&units=I"
        }
        
        apiQueue.asyncAfter(deadline: .now() + idx * 1.25) {
            if let url = URL(string: urlAddress) {
                let request = URLRequest(url: url)
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data = data {
                        do {
                            let decodedResponse = try JSONDecoder().decode(WeatherBitForecast.self, from: data)
                            let resultData = decodedResponse.data.filter( { $0.valid_date == dateString })
                            var result = WeatherBitForecast(data: resultData, city_name: decodedResponse.city_name)
                            if result.data.count == 0 {
                                DispatchQueue.main.async { [self] in
                                    self.setLocationForecast(tripID: tripId, locationID: location.id, forecast: nil, status: .dateTooFar)
                                }
                                
                            }
                            else {
                                if !UserDefaults.standard.bool(forKey: "isUsingImperial") {
                                    //Converting from m/s to km/h
                                    result.data[0].wind_spd *= 3.6
                                    result.data[0].wind_gust_spd *= 3.6
                                }
                                DispatchQueue.main.async { [self] in
                                    self.setLocationForecast(tripID: tripId, locationID: location.id, forecast: result, status: .loaded)
                                }
                            }
                        } catch {
                            print(error)
                            DispatchQueue.main.async { [self] in
                                self.setLocationForecast(tripID: tripId, locationID: location.id, forecast: nil, status: .error)
                            }
                        }
                        
                    }
                }.resume()
            } else {
                print("ERROR!! \(String(describing: self)) - URL returned nil!")
                return
            }
        }
        
    }
    
    //MARK: Sorting
    func sort(sortMethod: TripsView.SortMethod) {
        switch(sortMethod) {
        case .startDateAsc:
            model.sortTripsByStartDate(asc: true)
        case .startDateDsc:
            model.sortTripsByStartDate(asc: false)
        case .createdAsc:
            model.sortTripsByCreation(asc: true)
        case .createdDsc:
            model.sortTripsByCreation(asc: false)
        case .name:
            model.sortTripsByName()
        }
    }
    
}


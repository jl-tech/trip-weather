//
//  TripDetailView.swift
//  TripDetailView
//
//  Created by Jonathan Liu on 3/9/21.
//

import SwiftUI

struct TripDetailView: View {
    @EnvironmentObject var viewModel: TripsViewModel
    var trip: TripsViewModel.Trip
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach (trip.locations) { location in
                    if locationIsOnNewDate(location) {
                        Text(toLongDateString(from: location.day).uppercased())
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                    }
                    WeatherCard(location: location)
                }
            }.onAppear {
                viewModel.loadWeatherForTrip(trip)
            }
        }.navigationTitle(trip.name)
    }
    
    private func locationIsOnNewDate(_ location: TripsViewModel.Location) -> Bool {
        if let idx = trip.locations.firstIndex(where: { $0.id == location.id }) {
            if idx == 0 {
                return true
            }
            else {
                if trip.locations[idx - 1].day == location.day {
                    return false
                } else {
                    return true
                }
            }
        }
        return false
    }
}

struct WeatherCard: View {
    let location: TripsViewModel.Location
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                .foregroundColor(.blue)
            if location.weatherLoadStatus == .loading {
                ProgressView()
            }
            else {
                VStack(alignment: .leading) {
                    Text(location.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.all)
                    Text(String(describing: location.forecast))
                }
            }
        }
        .frame(height: 300)
        .padding([.bottom, .leading, .trailing])
        
    }
}



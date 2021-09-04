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
                    WeatherCard(location: location)
                }
            }.onAppear {
                viewModel.loadWeatherForTrip(trip)
            }
        }
    }
    
    
    
}

struct WeatherCard: View {
    let location: TripsViewModel.Location
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                .foregroundColor(.white)
            if location.weatherLoadStatus == .loading {
                ProgressView()
            }
            else {
                Text(String(describing: location.forecast))
            }
                
        }
        
    }
}



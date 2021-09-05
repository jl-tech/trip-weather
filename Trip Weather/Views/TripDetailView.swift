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
    @State var showEdit = false
    @State var editingExistingTrip = true
    
    var body: some View {
        ScrollView {
            VStack {
                nameHeader
                    .frame(height: 200)
                
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
        }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEdit) {
                AddEditTripView(editingExistingTrip: $editingExistingTrip)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    editToolbarButton
                }
                
            }
            
    }
    
    @ViewBuilder
    var editToolbarButton: some View {
        Button( action: {
            viewModel.setActiveTrip(id: trip.id)
            editingExistingTrip = true
            showEdit = true
        }) {
            Text("Edit")
        }
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
    
    @ViewBuilder
    var nameHeader: some View {
        ZStack (alignment: .bottom) {
            GeometryReader { geometry in
                if trip.image == nil {
                    Image("sample")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    Image(uiImage: UIImage(data: trip.image!)!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
                VStack() {
                    Spacer()
                    Text(trip.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Collapsible(label: { Text(" Details") }) {
                        VStack {
                            Text("Description")
                                .fontWeight(.bold)
                            Text(trip.description)
                            Text("Dates")
                                .fontWeight(.bold)
                                .padding(.top, 1.0)
                            
                            Text(Date.isBetweenDates(check: Date(), startDate: trip.startDate, endDate: trip.endDate) ? " in progress" : trip.startDate.relativeTime())
                            Text(" \(toLongDateString(from:trip.startDate)) - \(toLongDateString(from:trip.endDate))")
                                .padding(.bottom, 1.0)
                        }
                    }
                }
                .padding([.leading, .trailing])
                .shadow(radius: 5)
                .foregroundColor(.white)
                .animation(.easeInOut)
                
            }
            
        }
    }
}

struct WeatherCard: View {
    let location: TripsViewModel.Location
    @State var background: LinearGradient = LinearGradient(colors: [.gray, .blue], startPoint: .top, endPoint: .bottom)
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                .fill(background)
            if location.weatherLoadStatus == .loading {
                ProgressView()
            }
            else {
                VStack(alignment: .leading) {
                    Text(location.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if location.weatherLoadStatus == .unavailable {
                        Text("Weather unavailable")
                    } else if location.weatherLoadStatus == .loaded {
                        forecastInfo
                            .onAppear {
                                background = getGradientForCondition(conditionCode: location.forecast!.data[0].weather.code)
                            }
                    }
                }
                .padding(.all)
            }
        }
        .foregroundColor(.white)
        .padding([.bottom, .trailing, .leading])
        .frame(height: 300)
        
        
    }
    
    
    var conditionsBlock: some View {
        HStack {
            Image(location.forecast!.data[0].weather.icon)
                .resizable()
                .frame(width: 50, height: 50)
            Text(String(location.forecast!.data[0].weather.description))
        }
        
    }
    
    var tempsBlock: some View {
        HStack {
            VStack (alignment: .center) {
                Text(String(location.forecast!.data[0].high_temp))
                    .font(.title2)
                Text("HIGH")
                    .fontWeight(.bold)
            }
            VStack (alignment: .center) {
                Text(String(location.forecast!.data[0].low_temp))
                    .font(.title2)
                Text("LOW")
                    .fontWeight(.bold)
            }
            
        }
        .foregroundColor(.white)
    }
    
    var rainBlock: some View {
        HStack {
            VStack (alignment: .center) {
                Text(String(location.forecast!.data[0].pop))
                    .font(.title2)
                HStack {
                    Text("%")
                        .fontWeight(.bold)
                    Image(systemName: "drop.fill")
                }
            }
            VStack (alignment: .center) {
                Text(String(location.forecast!.data[0].precip))
                    .font(.title2)
                HStack {
                    Text("MM")
                        .fontWeight(.bold)
                    Image(systemName: "drop.fill")
                }
            }
        }
        .foregroundColor(.white)
    }
    
    var sunBlock: some View {
        HStack {
            VStack (alignment: .center) {
                Text(String(location.forecast!.data[0].uv))
                    .font(.title2)
                HStack {
                    Text("UV")
                        .fontWeight(.bold)
                }
            }
            VStack (alignment: .center) {
                Text(String(toTimeString(from: location.forecast!.data[0].sunrise_ts)))
                    .font(.title2)
                HStack {
                    Image(systemName: "sunrise.fill")
                }
            }
            VStack (alignment: .center) {
                Text(String(toTimeString(from: location.forecast!.data[0].sunset_ts)))
                    .font(.title2)
                HStack {
                    Image(systemName: "sunset.fill")
                }
            }
        }
    }
    
    @ViewBuilder
    var forecastInfo: some View {
        Text("FORECAST")
            .fontWeight(.bold)
            .foregroundColor(.white)
        conditionsBlock
        tempsBlock
            .padding(.top)
        rainBlock
            .padding(.top)
        sunBlock
            .padding(.top)
    }
    
    func getGradientForCondition(conditionCode: Int) -> LinearGradient {
        var colors: [Color] = []
        
        // Day: sunny condition, blue sky gradient
        if conditionCode >= 800, conditionCode <= 801 {
            colors.append(Color(hex: "A9E7FC"))
            colors.append(Color(hex: "2B6CFD"))
        }
        // Partly cloudy conditions, blue-gray
        else if conditionCode == 802 {
            colors.append(Color(hex: "2B6CFD"))
            colors.append(Color(hex: "d6d6d6"))
        }
        // Day: overcast conditions, light gray gradient
        else if conditionCode == 803 || conditionCode == 804 {
            colors.append(Color(hex: "d6d6d6"))
            colors.append(Color(hex: "a6a6a6"))
        }
        
        // Otherwise: Rain/Snow  conditions, dark gray gradient
        else {
            colors.append(Color(hex: "a6a6a6"))
            colors.append(Color(hex: "737373"))
        }
        
        return LinearGradient(gradient: Gradient(colors: colors), startPoint: .bottom, endPoint: .top)
        
    }
}


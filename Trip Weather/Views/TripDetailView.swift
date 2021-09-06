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
            ScrollViewReader { value in
                VStack {
                    nameHeader
                        .frame(height: 200)
                    Button( action: {
                        withAnimation {
                            value.scrollTo(Date.stripTime(from: Date()), anchor: .top)
                        }
                    }) {
                        Text("Scroll to today")
                            .font(.title2)
                            .padding(.bottom)
                    }
                    ForEach (trip.locations) { location in
                        if locationIsOnNewDate(location) {
                            Text(toLongDateString(from: location.day).uppercased())
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .id(location.day)
                        }
                        WeatherCard(location: location)
                    }
                    
                }.onAppear {
                    viewModel.loadWeatherForTrip(trip)
                }
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
                    HStack {
                        Text(Date.isBetweenDates(check: Date(), startDate: trip.startDate, endDate: trip.endDate) ? " in progress" : trip.startDate.relativeTime())
                        Spacer()
                        Collapsible(label: { Text("Details") }) {
                            ScrollView {
                                VStack {
                                    Text("Description")
                                        .fontWeight(.bold)
                                    Text(trip.description)
                                    Text("Dates")
                                        .fontWeight(.bold)
                                        .padding(.top, 1.0)
                                    Text(" \(toLongDateString(from:trip.startDate)) - \(toLongDateString(from:trip.endDate))")
                                        .padding(.bottom, 1.0)
                                    Text("Trip created")
                                        .fontWeight(.bold)
                                        .padding(.top, 1.0)
                                    Text(toLongDateString(from:trip.timestampAdded) + " " + toTimeString(from: trip.timestampAdded))
                                }
                            }
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
                        if location.day < Date.stripTime(from: Date()) {
                            HStack {
                                Text("Tap to view historical weather")
                                    .fontWeight(.bold)
                                Image(systemName: "chevron.right")
                                    .onAppear {
                                        background = LinearGradient(colors: [.gray, .gray], startPoint: .top, endPoint: .bottom)
                                    }
                            }
                        } else {
                            Text("Weather unavailable. Try again later.")
                        }
                        
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
        .frame(height: location.weatherLoadStatus != .unavailable ? 325 : 80)
        
        
    }
    
    
    var conditionsBlock: some View {
        HStack {
            Image(location.forecast!.data[0].weather.icon)
                .resizable()
                .frame(width: 50, height: 50)
            Text(String(location.forecast!.data[0].weather.description))
        }
        .padding([.top, .bottom], -5)
    }
    
    var tempsBlock: some View {
        HStack {
            HStack {
                Text(String(location.forecast!.data[0].high_temp) + "°")
                    .font(.title)
                Image(systemName: "arrow.up")
            }
            HStack {
                Text(String(location.forecast!.data[0].low_temp) + "°")
                    .font(.title)
                Image(systemName: "arrow.down")
                
            }
        }
        .foregroundColor(.white)
    }
    
    var rainBlock: some View {
        HStack {
            Image(systemName: "cloud.rain.fill")
            Text("RAIN:")
                .fontWeight(.bold)
            Text(String(format:"%g", location.forecast!.data[0].pop.rounded()))
                .font(.title2)
            Text("% ")
                .padding(.leading, -5)
            Text(String(format:"%g", location.forecast!.data[0].precip.rounded()))
                .font(.title2)
            Text("MM ")
                .padding(.leading, -5)
        }
        .foregroundColor(.white)
    }
    
    var sunBlock: some View {
        HStack {
            Image(systemName: "sun.max.fill")
            Text("SUN:")
                .fontWeight(.bold)
            
            Text(String(format:"%g", location.forecast!.data[0].uv.rounded()))
                .font(.title2)
            Text("UV ")
                .padding(.leading, -5)
            
            HStack (alignment: .center) {
                Text(String(toTimeString(from: location.forecast!.data[0].sunrise_ts)))
                    .font(.title3)
                Image(systemName: "sunrise.fill")
                    .padding(.leading, -5)
                
            }
            
            HStack (alignment: .center) {
                Text(String(toTimeString(from: location.forecast!.data[0].sunset_ts)))
                    .font(.title3)
                Image(systemName: "sunset.fill")
                    .padding(.leading, -5)
            }
            
        }
    }
    
    var windBlock: some View {
        HStack {
            Image(systemName: "wind")
            Text("WIND:")
                .fontWeight(.bold)
            
            Text(String(format:"%g", location.forecast!.data[0].wind_spd.rounded()) + " / " + String(format:"%g", location.forecast!.data[0].wind_gust_spd.rounded()) + "G")
                .font(.title2)
            Text("KM/H ")
                .padding(.leading, -5)
            Text(String(location.forecast!.data[0].wind_cdir))
                .font(.title2)
            Text("DIR ")
                .padding(.leading, -5)
            
        }
    }
    
    var otherBlock: some View {
        HStack {
            Text(String(format:"%g", location.forecast!.data[0].vis.rounded()))
                .font(.title2)
            Text("KM VIS ")
                .padding(.leading, -5)
            Text(String(format:"%g", location.forecast!.data[0].rh.rounded()))
                .font(.title2)
            Text("% HUMIDITY ")
                .padding(.leading, -5)
            
        }
    }
    
    @ViewBuilder
    var forecastInfo: some View {
        conditionsBlock
        tempsBlock
            .padding(.bottom, 0.5)
        rainBlock
        sunBlock
            .padding(.top, 1.0)
        windBlock
            .padding(.top, 1.0)
        otherBlock
            .padding(.top, 1.0)
    }
    
    func getGradientForCondition(conditionCode: Int) -> LinearGradient {
        var colors: [Color] = []
        
        // Day: sunny condition, blue sky gradient
        if conditionCode >= 800, conditionCode <= 801 {
            colors.append(Color(hex: "7AB9FC"))
            colors.append(Color(hex: "2B6CFD"))
        }
        // Partly cloudy conditions, blue-gray
        else if conditionCode == 802 {
            colors.append(Color(hex: "b0b0b0"))
            colors.append(Color(hex: "2B6CFD"))
            
        }
        // Day: overcast conditions, light gray gradient
        else if conditionCode == 803 || conditionCode == 804 {
            colors.append(Color(hex: "b0b0b0"))
            colors.append(Color(hex: "808080"))
            
        }
        // Otherwise: Rain/Snow  conditions, dark gray gradient
        else {
            colors.append(Color(hex: "737373"))
            colors.append(Color(hex: "4f4f4f"))
            
        }
        
        return LinearGradient(gradient: Gradient(colors: colors), startPoint: .bottom, endPoint: .top)
        
    }
}


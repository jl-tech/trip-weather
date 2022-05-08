//
//  LocationSelectionView.swift
//  LocationSelectionView
//
//  Created by Jonathan Liu on 31/8/21.
//

import SwiftUI
import MapKit

struct LocationSelectionView: View {
    @State var forDate: Date
    @EnvironmentObject var viewModel: TripsViewModel

    
    var body: some View {
        VStack {
            dateSwitcher
            Form {
                Section(header: Text("Add location"), footer: Text("Select one or more cities/towns.")) {
                    NewEntryView(locationService: LocationService(), forDate: forDate)
                }
                Section(header: Text("Selected Locations"), footer: Text("Swipe a location to the left to delete it. Tap to view its map.")) {
                    if viewModel.locationsWithDate(forDate).count == 0 {
                        Text("No locations selected")
                            .foregroundColor(.gray)
                    }
                    else {
                        List {
                            ForEach(viewModel.activeTrip.locations) { location in
                                if (location.day == forDate) {
                                    NavigationLink(destination: LocationMapView(location: location)) {
                                        Text(location.name)
                                    }
                                }
                            }
                            .onDelete { offsets in
                                viewModel.activeTrip.locations.remove(atOffsets: offsets)
                            }
    
                            
                        }
                        
                    }
                }
                
            }
        }.navigationTitle("Select Locations")
    }
    
    @ViewBuilder
    var dateSwitcher: some View {
        HStack {
            Button(action: {
                forDate = Calendar.current.date(byAdding: .day, value: -1, to: forDate)!
            }) {
                Image(systemName: "arrow.backward")
            }
            .disabled(!moreDatesBefore)
            Text(toLongDateString(from: forDate))
                .font(.title)
            Button(action: {
                forDate = Calendar.current.date(byAdding: .day, value: 1, to: forDate)!
            }) {
                Image(systemName: "arrow.forward")
            }
            .disabled(!moreDatesAfter)
        }
        

    }
    
    private var moreDatesBefore: Bool {
        forDate > viewModel.activeTrip.startDate
    }
    
    private var moreDatesAfter: Bool {
        forDate < viewModel.activeTrip.endDate
    }
    
}

// Based off code by Peter Alt
struct NewEntryView: View {
    @ObservedObject var locationService: LocationService
    @EnvironmentObject var viewModel: TripsViewModel
    
    var forDate: Date
    
    var body: some View {
        ZStack(alignment: .trailing) {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $locationService.queryFragment)
            }
            if locationService.status == .isSearching {
                ProgressView()
            }
        }
        List {
            switch locationService.status {
                case .noResults: AnyView(Text("No Results"))
                case .error(let description):  AnyView(Text("Error: \(description)"))
                default:  AnyView(EmptyView())
            }
            
            ForEach(locationService.searchResults, id: \.self) { completionResult in
                Button(action: {
                    var name = completionResult.title + ", " + completionResult.subtitle
                    if name.suffix(2) == ", " {
                        name = String(name.dropLast().dropLast())
                    }
                    locationService.getCoordinate(addressString: name) { coords, error in
                        print(coords)
                        print(toLongDateString(from: forDate))
                        viewModel.addLocation(day: forDate, latitude: coords.latitude, longitude: coords.longitude, name: name)
                    }
                    locationService.queryFragment = ""
                } ) {
                    Text(completionResult.title + ", " + completionResult.subtitle)
                }
            }
        }
        
    
    }
}
//struct LocationSelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        //LocationSelectionView()
//    }
//}

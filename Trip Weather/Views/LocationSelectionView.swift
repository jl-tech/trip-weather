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
                    if viewModel.tripToAdd.locations.count == 0 {
                        Text("No locations selected yet")
                            .foregroundColor(.gray)
                    }
                    else {
                        List {
                            ForEach(viewModel.tripToAdd.locations) { location in
                                if (location.day == forDate) {
                                    NavigationLink(destination: LocationMapView(location: location)) {
                                        Text(location.name)
                                    }
                                }
                            }
                            .onDelete { offsets in
                                viewModel.tripToAdd.locations.remove(atOffsets: offsets)
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

            }) {
                Image(systemName: "arrow.backward")
            }
            .disabled(!moreDatesBefore)
            Text(toDateString(from: forDate))
                .font(.title)
            Button(action: {
                
            }) {
                Image(systemName: "arrow.forward")
            }
            .disabled(!moreDatesAfter)
        }
        

    }
    
    private var moreDatesBefore: Bool {
        forDate > viewModel.tripToAdd.startDate
    }
    
    private var moreDatesAfter: Bool {
        forDate < viewModel.tripToAdd.endDate
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
                // This simply lists the results, use a button in case you'd like to perform an action
                // or use a NavigationLink to move to the next view upon selection.
                Button(action: {
                    let name = completionResult.title + ", " + completionResult.subtitle
                    locationService.getCoordinate(addressString: name) { coords, error in
                        print(coords)
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

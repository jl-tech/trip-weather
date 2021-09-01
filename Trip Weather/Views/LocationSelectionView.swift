//
//  LocationSelectionView.swift
//  LocationSelectionView
//
//  Created by Jonathan Liu on 31/8/21.
//

import SwiftUI
import MapKit

struct LocationSelectionView: View {
    var forDate: Date
    @EnvironmentObject var viewModel: TripsViewModel

    @Binding var completionStatus: AddTripView.DateEntry.status
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Add location"), footer: Text("Select one or more locations you will be at during \(toDateString(from: forDate))")) {
                    NewEntryView(locationService: LocationService(), completionStatus: $completionStatus, forDate: forDate)
                }
                Section(header: Text("Selected Locations")) {
                    if viewModel.tripToAdd.locations.count == 0 {
                        Text("No locations selected yet")
                            .foregroundColor(.gray)
                    }
                    else {
                        List(viewModel.tripToAdd.locations) { location in
                            if (location.day == forDate) {
                                Text(location.name)
                            }
                        }
                    }
                }
                
            }
        }.navigationTitle("Select Locations")
    }
}

// Based off code by Peter Alt
struct NewEntryView: View {
    @ObservedObject var locationService: LocationService
    @EnvironmentObject var viewModel: TripsViewModel
    @Binding var completionStatus: AddTripView.DateEntry.status
    
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
                        completionStatus = .finished
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

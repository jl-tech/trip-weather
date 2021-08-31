//
//  AddTripView.swift
//  AddTripView
//
//  Created by Jonathan Liu on 31/8/21.
//

import SwiftUI

struct AddTripView: View {
    @Binding var trip: TripsViewModel.Trip
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                basicsSection
                dateSection
                locationsSection
                Button(action: {}) {
                    Text("Create Trip")
                }
            }
            .navigationTitle("New Trip")
            .frame(minWidth: 400, minHeight: 600)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() } ) {
                        Text("Cancel")
                    }
                }
            }
        }
    }
        func dismiss() {
            
            presentationMode.wrappedValue.dismiss()
        }
        
        
        
        
    
    
    var basicsSection: some View {
        Group {
            Section (header: Text("Name")) {
                TextField("Name this trip!", text: $trip.name)
            }
            Section(header: Text("Description")) {
                TextField("Give this trip a description", text: $trip.name)
            }
        }
    }
    
    var dateSection: some View {
        Section (header: Text("Dates")) {
            DatePicker("Start Date",
                       selection: $trip.startDate,
                       displayedComponents: [.date])
            DatePicker("End Date",
                       selection: $trip.endDate,
                       displayedComponents: [.date])
        }
    }
    
    var locationsSection: some View {
        Section (header: Text("Locations")) {
            if trip.endDate < trip.startDate {
                Text("Trip end date must be on or after start date")
                    .foregroundColor(Color.gray)
            } else {
                List {
                    ForEach(Date.dates(from: trip.startDate, to: trip.endDate)) { date in
                        DateEntry(locations: $trip.locations, date: date)
                    }
                }
            }
        }

    }
    
    struct DateEntry: View {
        @Binding var locations: [TripsViewModel.Location]
        var date: Date
        @State var currStatus = status.incomplete
        
        var body: some View {
            NavigationLink(destination: LocationSelectionView(locations: $locations, forDate: date, completionStatus: $currStatus)) {
                VStack(alignment:.leading) {
                    Text(toDateString(from:date))
                    switch (currStatus) {
                    case .finished:
                        HStack {
                        Image(systemName: "checkmark.circle")
                        Text("Location: [LOC]")
                            .font(.caption)
                            
                        }
                        .foregroundColor(Color.green)
                    case .incomplete:
                        HStack {
                        Image(systemName: "exclamationmark.circle")
                        Text("Location not added yet")
                            .font(.caption)
                            
                        }
                        .foregroundColor(Color.red)
                        
                    }
                    
                }
            }
            
        }
        
        enum status {
            case finished
            case incomplete
        }
    }
}


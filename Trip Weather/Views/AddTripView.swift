//
//  AddTripView.swift
//  AddTripView
//
//  Created by Jonathan Liu on 31/8/21.
//

import SwiftUI

struct AddTripView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var viewModel: TripsViewModel
    
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
                TextField("Name this trip!", text: $viewModel.tripToAdd.name)
            }
            Section(header: Text("Description")) {
                TextField("Give this trip a description", text: $viewModel.tripToAdd.name)
            }
        }
    }
    
    var dateSection: some View {
        Section (header: Text("Dates")) {
            DatePicker("Start Date",
                       selection: $viewModel.tripToAdd.startDate,
                       displayedComponents: [.date])
            DatePicker("End Date",
                       selection: $viewModel.tripToAdd.endDate,
                       displayedComponents: [.date])
        }
    }
    
    var locationsSection: some View {
        Section (header: Text("Locations")) {
            if viewModel.tripToAdd.endDate < viewModel.tripToAdd.startDate {
                Text("Trip end date must be on or after start date")
                    .foregroundColor(Color.gray)
            } else {
                List {
                    ForEach(Date.dates(from: viewModel.tripToAdd.startDate, to: viewModel.tripToAdd.endDate)) { date in
                        DateEntry(date: date, viewModel: $viewModel)
                    }
                }
            }
        }

    }
    
    struct DateEntry: View {
        var date: Date
        @State var currStatus = status.incomplete
        @Binding var viewModel: TripsViewModel
        
        var body: some View {
            NavigationLink(destination: LocationSelectionView(forDate: date, viewModel: $viewModel, completionStatus: $currStatus)) {
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


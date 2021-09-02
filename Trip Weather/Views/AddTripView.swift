//
//  AddTripView.swift
//  AddTripView
//
//  Created by Jonathan Liu on 31/8/21.
//

import SwiftUI

struct AddTripView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: TripsViewModel
    @State private var photoMode: PhotoMode = .automatic
    @State private var photoSelectionStatus: PhotoSelectionStatus = .unselected
    @State private var showConfirmResetPrompt = false

    var body: some View {
        NavigationView {
            Form {
                basicsSection
                dateSection
                locationsSection
                photoSection
                Button(action: {
                    doCreateTrip()
                }) {
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
                ToolbarItem(placement: .destructiveAction) {
                    Button(action: { showConfirmResetPrompt = true } ) {
                        Text("Reset")
                            .foregroundColor(.red)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { doCreateTrip() } ) {
                        Text("Create")
                            .fontWeight(.semibold)
                    }
                }
            }
            .alert(isPresented: $showConfirmResetPrompt) {
                Alert(
                    title: Text("Confirm reset"),
                    message: Text("Are you sure you want to reset this page? All entered data will be permanently lost!"),
                    primaryButton: .destructive(Text("Reset")) {
                        viewModel.resetToAdd()
                    },
                    secondaryButton: .cancel())
            }
            .onAppear {
                photoSelectionStatus =  (viewModel.tripToAdd.image == nil ? .unselected : .selected)
            }
        }
        .alert(isPresented: $showFormIncompletePrompt) {
            Alert(
                title: Text("Couldn't create trip"),
                message: Text(formIncompleteReason),
                dismissButton: .default(Text("OK")) {
                    formIncompleteReason = "The trip couldn't be created because"
                })
        }
    }
    
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
    
    @State private var showFormIncompletePrompt = false
    @State private var formIncompleteReason = "The trip couldn't be created because:"
    func doCreateTrip() {
        let currTrip = viewModel.tripToAdd
        var willShowPrompt = false
        
        if currTrip.name.isEmpty {
            formIncompleteReason += "\n- You haven't entered a Name"
            willShowPrompt = true
        }
        
        if currTrip.description.isEmpty {
            formIncompleteReason += "\n- You haven't entered a Description"
            willShowPrompt = true
            
        }
        
        if currTrip.endDate < currTrip.startDate {
            formIncompleteReason += "\n- Trip end date must be on or before start date"
            willShowPrompt = true
        }
        
        for date in Date.dates(from: currTrip.startDate, to: currTrip.endDate) {
            if viewModel.nLocationsWithDate(date) == 0 {
                formIncompleteReason += "\n- No location was entered for \(toDateString(from: date))"
                willShowPrompt = true
            }
            
        }
        
        if photoMode == .selection && currTrip.image == nil {
            formIncompleteReason += "\n- No photo was selected"
            willShowPrompt = true
            
        }
        
        if willShowPrompt {
            showFormIncompletePrompt = true
        } else {
            viewModel.doCreateTrip()
            dismiss()
            viewModel.resetToAdd()
        }
    }
    
    
    
    
    
    var basicsSection: some View {
        Group {
            Section (header: Text("Name")) {
                TextField("Name this trip!", text: $viewModel.tripToAdd.name)
            }
            Section(header: Text("Description")) {
                TextField("Give this trip a description", text: $viewModel.tripToAdd.description)
            }
        }
    }
    
    var dateSection: some View {
        Section (
            header: Text("Dates"),
            footer:
                HStack {
                    Image(systemName: viewModel.tripToAdd.endDate < viewModel.tripToAdd.startDate  ? "exclamationmark.circle" : "checkmark.circle")
                        .foregroundColor(viewModel.tripToAdd.endDate < viewModel.tripToAdd.startDate  ? .red : .green)
                    Text(viewModel.tripToAdd.endDate < viewModel.tripToAdd.startDate  ? "End date must be on or after start date" : "Dates look good")
                        .font(.caption)
                        .foregroundColor(viewModel.tripToAdd.endDate < viewModel.tripToAdd.startDate  ? .red : .green)
                    
                }
        ){
            DatePicker("Start date",
                           selection: $viewModel.tripToAdd.startDate,
                           displayedComponents: [.date])
                DatePicker("End date",
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
                        DateEntry(date: date)
                    }
                }
            }
            
        }
    }
    
    
    var photoSection: some View {
        Section (header: Text("Photo"), footer: Text("'Automatic photos from the web' will display top photos of locations as your trip progresses.")) {
            Picker(selection: $photoMode, label: EmptyView()) {
                Text("Automatic photos from the web").tag(PhotoMode.automatic)
                Text("Select from my photos").tag(PhotoMode.selection)
            }
            .pickerStyle(InlinePickerStyle())
            if photoMode == .selection {
                NavigationLink(destination: PhotoSelectionView(photoSelectionStatus: $photoSelectionStatus)) {
                    VStack {
                        Text("Select photo")
                        HStack {
                            Image(systemName: photoSelectionStatus == .unselected ? "exclamationmark.circle" : "checkmark.circle")
                            Text(photoSelectionStatus == .unselected ? "No photo selected" : "Photo selected")
                                .font(.caption)
                        }
                        .foregroundColor(photoSelectionStatus == .unselected ? .red : .green)
                    }
                    
                }
            }
        }
        
        
    }
    
    enum PhotoSelectionStatus {
        case unselected
        case selected
    }
    
    enum PhotoMode {
        case automatic
        case selection
    }
    
    struct DateEntry: View {
        var date: Date
        @State var currStatus = status.incomplete
        @EnvironmentObject var viewModel: TripsViewModel
        
        var body: some View {
            NavigationLink(destination: LocationSelectionView(forDate: date)) {
                VStack(alignment:.leading) {
                    Text(toDateString(from:date))
                    if (viewModel.locationsWithDate(date).count > 0) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            if (viewModel.locationsWithDate(date).count == 1) {
                                Text(viewModel.locationsWithDate(date)[0].name)
                                    .font(.caption)
                            } else {
                                Text("\(viewModel.locationsWithDate(date).count) locations")
                                    .font(.caption)
                            }
                            
                        }
                        .foregroundColor(Color.green)
                    } else {
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


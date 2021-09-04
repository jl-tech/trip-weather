//
//  AddTripView.swift
//  AddTripView
//
//  Created by Jonathan Liu on 31/8/21.
//

import SwiftUI

struct AddEditTripView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: TripsViewModel
    @State private var photoMode: PhotoMode = .automatic
    @State private var photoSelectionStatus: PhotoSelectionStatus = .unselected
    @State private var showConfirmResetPrompt = false
    @Binding var editingExistingTrip: Bool

    var body: some View {
        NavigationView {
            Form {
                basicsSection
                dateSection
                locationsSection
                photoSection
                Button(action: {
                    doCreateOrEdit()
                }) {
                    Text("Create Trip")
                }
            }
            .navigationTitle(editingExistingTrip ? "Edit Trip": "New Trip")
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
                    Button(action: { doCreateOrEdit() } ) {
                        Text(editingExistingTrip ? "Edit" : "Create")
                            .fontWeight(.semibold)
                    }
                }
                    
            }
            .alert(isPresented: $showConfirmResetPrompt) {
                Alert(
                    title: Text("Confirm reset"),
                    message: Text("Are you sure you want to reset this page? All entered data will be permanently lost!"),
                    primaryButton: .destructive(Text("Reset")) {
                        reset()
                    },
                    secondaryButton: .cancel())
            }
            .onAppear {
                onAppearTasks()
            }
        }
        .alert(isPresented: $showFormIncompletePrompt) {
            Alert(
                title: Text("Field(s) incomplete"),
                message: Text(formIncompleteReason),
                dismissButton: .default(Text("OK")))
        }
    }
    
    func onAppearTasks() {
        photoMode = (viewModel.activeTrip.image == nil ? .automatic : .selection)
        photoSelectionStatus =  (viewModel.activeTrip.image == nil ? .unselected : .selected)
            
    }
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
        editingExistingTrip = false
        viewModel.resetActiveTrip()
    }
    
    @State private var showFormIncompletePrompt = false
    @State private var formIncompleteReason = ""
    func doCreateOrEdit() {
        formIncompleteReason = editingExistingTrip ? "The trip couldn't be edited because" : "The trip couldn't be created because"
        let currTrip = viewModel.activeTrip
        var willShowPrompt = false
        
        if currTrip.name.isEmpty {
            formIncompleteReason += "\n- You haven't entered a Name"
            willShowPrompt = true
        }
        
        if Date.isSameDayOrBeforeDate(check: viewModel.activeTrip.endDate, against: viewModel.activeTrip.startDate)  {
            formIncompleteReason += "\n- Trip end date must be on or before start date"
            willShowPrompt = true
        }
        
        var datesMissingLocs: [Date] = []
        for date in Date.dates(from: currTrip.startDate, to: currTrip.endDate) {
            if viewModel.nLocationsWithDate(date) == 0 {
                datesMissingLocs.append(date)
            }
        }
        
        if datesMissingLocs.count == 1 {
            formIncompleteReason += "\n- Missing location for \(toLongDateString(from: datesMissingLocs[0]))"
            willShowPrompt = true
        }
        else if datesMissingLocs.count > 1{
            formIncompleteReason += "\n- Missing locations for multiple dates"
            willShowPrompt = true
        }
        
        if photoMode == .selection && currTrip.image == nil {
            formIncompleteReason += "\n- No photo was selected"
            willShowPrompt = true
            
        }
        
        if willShowPrompt {
            showFormIncompletePrompt = true
        } else {
            if photoMode == .automatic {
                viewModel.activeTrip.image = nil
            }
            if editingExistingTrip {
                viewModel.doEditTrip()
            } else {
                viewModel.doCreateTrip()
            }
            dismiss()
            reset()
        }
    }
    
    private func reset() {
        photoSelectionStatus = .unselected
        photoMode = .automatic
        viewModel.resetToAdd()
    }
    
    
    
    var basicsSection: some View {
        Group {
            Section (
                header: Text("Name"),
                footer:
                    HStack {
                        Image(systemName: viewModel.activeTrip.name.isEmpty ? "exclamationmark.circle" : "checkmark.circle")
                        Text(viewModel.activeTrip.name.isEmpty ? "Name is required" : "Nice name!")
                    }.foregroundColor(viewModel.activeTrip.name.isEmpty  ? .red : .green)
                    .font(.caption)
            ) {
                TextField("Name", text: $viewModel.activeTrip.name)
                
            }
            Section(header: Text("Description")) {
                TextField("Description (optional)", text: $viewModel.activeTrip.description)
            }
        }
    }
    
    var dateSection: some View {
        Section (
            header: Text("Dates"),
            footer:
                HStack {
                    Image(systemName: Date.isSameDayOrBeforeDate(check: viewModel.activeTrip.endDate, against: viewModel.activeTrip.startDate) ? "exclamationmark.circle" : "checkmark.circle")
                    Text(Date.isSameDayOrBeforeDate(check: viewModel.activeTrip.endDate, against: viewModel.activeTrip.startDate)  ? "End date must be after start date" : "Dates look good")
                    
                }.foregroundColor(Date.isSameDayOrBeforeDate(check: viewModel.activeTrip.endDate, against: viewModel.activeTrip.startDate)  ? .red : .green)
                .font(.caption)
        ){
            DatePicker("Start date",
                           selection: $viewModel.activeTrip.startDate,
                           displayedComponents: [.date])
                DatePicker("End date",
                       selection: $viewModel.activeTrip.endDate,
                       displayedComponents: [.date])
        }
        
    }
    
    var locationsSection: some View {
        Section (header: Text("Locations")) {
            if Date.isSameDayOrBeforeDate(check: viewModel.activeTrip.endDate, against: viewModel.activeTrip.startDate)  {
                Text("End date must be after start date")
                    .foregroundColor(Color.gray)
            } else {
                List {
                    ForEach(Date.dates(from: viewModel.activeTrip.startDate, to: viewModel.activeTrip.endDate)) { date in
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
                        }
                        .foregroundColor(photoSelectionStatus == .unselected ? .red : .green)
                        .font(.caption)
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
                    Text(toLongDateString(from:date))
                    if (viewModel.locationsWithDate(date).count > 0) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            if (viewModel.locationsWithDate(date).count == 1) {
                                Text(viewModel.locationsWithDate(date)[0].name)
                            } else {
                                Text("\(viewModel.locationsWithDate(date).count) locations")
                            }
                            
                        }
                        .foregroundColor(Color.green)
                        .font(.caption)
                    } else {
                        HStack {
                            Image(systemName: "exclamationmark.circle")
                            Text("Location not added yet")
                        }
                        .foregroundColor(Color.red)
                        .font(.caption)
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


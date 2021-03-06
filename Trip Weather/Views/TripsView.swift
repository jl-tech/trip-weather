//
//  HomeView.swift
//  Trip Weather
//
//  Created by Jonathan Liu on 30/8/21.
//

import SwiftUI

struct TripsView: View {
    @EnvironmentObject var viewModel: TripsViewModel
    
    @State private var editMode = false
    @State private var addEditTripOpen = false
    @State private var editingExistingTrip = false
    
    @State private var currentSortMethod = SortMethod(rawValue: UserDefaults.standard.integer(forKey: "tripSortMethod")) ?? SortMethod.createdDsc
    
    var body: some View {
        ScrollView {
            LazyVStack {
                sortSelector
                ForEach(viewModel.trips()) { trip in
                    TripCard(trip: trip, editMode: $editMode, addEditTripOpen: $addEditTripOpen, editingExistingTrip: $editingExistingTrip)
                        .padding([.leading, .bottom, .trailing])
                        .frame(height: 250)
                }
                NewTripCard(addTripOpen: $addEditTripOpen)
                    .padding([.leading, .bottom, .trailing])
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                editToolbarButton
            }
            ToolbarItem(placement: .primaryAction) {
                newTripToolbarButton
            }
        }
        .sheet(isPresented: $addEditTripOpen) {
            AddEditTripView(editingExistingTrip: $editingExistingTrip)
        }
        .onAppear {
            viewModel.loadTrips()
        }
    }
    

    
    // MARK: Sorting
    enum SortMethod: Int {
        case createdAsc
        case createdDsc
        case startDateAsc
        case startDateDsc
        case name
    }
    
    var sortSelector: some View {
        HStack {
            Text("Sort by:")
                .font(.system(size: 15))
            Picker("Sort Order", selection: $currentSortMethod.onChange {_ in
                UserDefaults.standard.set(currentSortMethod.rawValue, forKey: "tripSortMethod")
                viewModel.sort(sortMethod: currentSortMethod)
            }) {
                Text("Date added (oldest first)").tag(SortMethod.createdAsc)
                Text("Date added (recent first)").tag(SortMethod.createdDsc)
                Text("Start date (oldest first)").tag(SortMethod.startDateAsc)
                Text("Start date (recent first)").tag(SortMethod.startDateDsc)
                Text("Name (alphabetical)").tag(SortMethod.name)
            }
            .pickerStyle(.menu)
        }
        
    }
    
    // MARK: Cards
    
    struct TripCard: View {
        let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
        var trip: TripsViewModel.Trip
        
        @Binding var editMode: Bool
        @Binding var addEditTripOpen: Bool
        @Binding var editingExistingTrip: Bool
        
        @State var showDeleteConfAlert = false
        @EnvironmentObject var viewModel: TripsViewModel
        @State private var action: Int? = 0
        
        var body: some View {
            VStack {
                NavigationLink(destination: TripDetailView(trip: trip), tag: 1, selection: $action) { EmptyView() }
                GeometryReader { geometry in
                    Button(action: { self.action = 1 }) {
                        ZStack(alignment: .bottom) {
                            if trip.image != nil {
                                Image(uiImage: UIImage(data: trip.image!)!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .contentShape(shape)
                            } else {
                                Image("sample")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .contentShape(shape)
                                
                            }
                            infoPart
                        }
                        .clipShape(shape)
                    }.buttonStyle(tapBounceButtonStyle())
                }
                
                controlsPart
            }
            
        }
        
        var infoPart: some View {
            VStack() {
                Text(trip.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 1.0)
                    .lineLimit(1)
                if viewModel.tripIsInProgress(trip: trip) {
                    Text(" in progress")
                } else {
                    Text(" \(trip.startDate.relativeTime())")
                        .font(.subheadline)
                }
                Text(" \(toLongDateString(from:trip.startDate)) - \(toLongDateString(from:trip.endDate))")
                    .font(.caption2)
                    .padding(.bottom, 1.0)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.black)
            .background(Blur(style: .systemUltraThinMaterialLight))
            .clipped()
        }
        
        @ViewBuilder
        var controlsPart: some View {
            if editMode {
                HStack {
                    Button(action: {
                        viewModel.setActiveTrip(id: trip.id)
                        editingExistingTrip = true
                        addEditTripOpen = true
                    }) {
                        Image(systemName: "pencil")
                        Text("Edit")
                            .fontWeight(.bold)
                            .font(.system(size: 12))
                    }
                    Button(action: {
                        showDeleteConfAlert = true
                    }) {
                        Image(systemName: "trash")
                        Text("Delete")
                            .fontWeight(.bold)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.red)
                }
                .font(.title2)
                .alert(isPresented: $showDeleteConfAlert) {
                    Alert(
                        title: Text("Confirm delete"),
                        message: Text("Are you sure you want to delete '\(trip.name)'? All associated data will be permanently lost!"),
                        primaryButton: .destructive(Text("Delete")) {
                            viewModel.removeTrip(trip)
                        },
                        secondaryButton: .cancel())
                }
            }
        }
    }
    
    struct NewTripCard: View {
        @Binding var addTripOpen: Bool
        var body: some View {
            Button(action: {
                addTripOpen = true
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                        .foregroundColor(.blue)
                    VStack {
                        Image(systemName: "plus.circle")
                        Text("Create a new trip")
                    }
                    
                    .foregroundColor(.white)
                }
            }
            .frame(height: 100)
            .buttonStyle(tapBounceButtonStyle())
        }
    }
    
    struct tapBounceButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.90 : 1)
                .animation(.easeInOut(duration: 0.15))
        }
    }
    
    
    
    // MARK: Toolbar
    @ViewBuilder
    var editToolbarButton: some View {
        Button() {
            editMode.toggle()
        } label: {
            Text(editMode ? "Done" : "Edit")
                .fontWeight(editMode ? .semibold : .regular)
        }
    }
    
    var newTripToolbarButton: some View {
        Button() {
            addEditTripOpen = true
        } label: {
            Image(systemName: "plus")
        }
        
    }
}

// MARK: Constants
struct DrawingConstants {
    static let cornerRadius: CGFloat = 20
    static let lineWidth: CGFloat = 3
}


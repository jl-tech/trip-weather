//
//  HomeView.swift
//  Trip Weather
//
//  Created by Jonathan Liu on 30/8/21.
//

import SwiftUI
import CoreData

struct TripsView: View {
    @EnvironmentObject var viewModel: TripsViewModel

    @State private var editMode = false
    @State private var addEditTripOpen = false
    @State private var editingExistingTrip = false
    
    var body: some View {
        ScrollView {
            LazyVStack {
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
    // MARK: Cards
    
    struct TripCard: View {
        let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
        var trip: TripsViewModel.Trip
        
        @Binding var editMode: Bool
        @Binding var addEditTripOpen: Bool
        @Binding var editingExistingTrip: Bool
        
        @State var showDeleteConfAlert = false
        @EnvironmentObject var viewModel: TripsViewModel
        
        var body: some View {
            VStack {
                GeometryReader { geometry in
                    Button(action: {
                        
                    }) {
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
                if Date.isBetweenDates(check: Date(), startDate: trip.startDate, endDate: trip.endDate) {
                    Text(" in progress")
                } else {
                    Text(" \(trip.startDate.relativeTime())")
                        .font(.subheadline)
                }
                Text(" \(toDateString(from:trip.startDate)) - \(toDateString(from:trip.endDate))")
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
                    }
                    Button(action: {
                        showDeleteConfAlert = true
                    }) {
                        Image(systemName: "trash")
                    }
                    .foregroundColor(.red)
                }
                .font(.title2)
                .alert(isPresented: $showDeleteConfAlert) {
                    Alert(
                        title: Text("Confirm delete"),
                        message: Text("Are you sure you want to delete '\(trip.name)? All associated data will be permanently lost!"),
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

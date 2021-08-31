//
//  HomeView.swift
//  Trip Weather
//
//  Created by Jonathan Liu on 30/8/21.
//

import SwiftUI
import CoreData

struct TripsView: View {
    @ObservedObject var viewModel: HomeViewModel = HomeViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(TestData.testTrips) { trip in
                    TripCard(trip: trip)
                        .padding([.leading, .bottom, .trailing])
                }
                NewTripCard()
                    .padding([.leading, .bottom, .trailing])
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                homeToolbar
            }
        }
    }
    
    struct TripCard: View {
        let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
        var trip: TripWeatherModel.STrip
        var body: some View {
            Button(action: {
                
            }) {
                ZStack(alignment: .bottom) {
                    Image("sample2")
                        .resizable()
                        .frame(height: 250)
                        .aspectRatio(contentMode: .fit)
                        
                    VStack() {
                        Text(trip.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 1.0)
                        Text(" \(trip.startDate.relativeTime())")
                            .font(.subheadline)
                        Text(" \(toDateString(from:trip.startDate)) - \(toDateString(from:trip.endDate))")
                            .font(.caption2)
                            .padding(.bottom, 1.0)
                        
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.black)
                    .background(Blur(style: .systemUltraThinMaterialLight))
                    .clipped()
                }
                .clipShape(shape)
            }
        }
    }
    
    
    
    struct tapBounceButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.90 : 1)
                .animation(.easeInOut(duration: 0.15))
        }
    }
    
    struct NewTripCard: View {
        var body: some View {
            Button(action: {
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                        .shadow(radius: 5, y: 3)
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
    
    var homeToolbar: some View {
        Group {
            
            
            Button() {
                // add
            } label: {
                Text("Edit")
            }
            
            Button() {
                // add
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

private struct DrawingConstants {
    static let cornerRadius: CGFloat = 20
    static let lineWidth: CGFloat = 3
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TripsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

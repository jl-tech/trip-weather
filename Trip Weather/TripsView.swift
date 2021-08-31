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
            VStack {
                ForEach(TestData.testTrips) { trip in
                    TripCard(trip: trip)
                }
                NewTripCard()
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
                    shape
                        .shadow(radius: 5)
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text(trip.name)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(trip.startDate.relativeTime())
                            .font(.subheadline)
                        Text("\(toDateString(from:trip.startDate)) - \(toDateString(from:trip.endDate))")
                            .font(.caption2)
                    }
                    .padding(.all)
                }
                
            }.buttonStyle(tapBounceButtonStyle())
                .frame(height: 250)
                .padding([.top, .leading, .trailing])
        }
    }
    
    struct tapBounceButtonStyle: ButtonStyle {
      func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.15))
      }
    }
    
    struct NewTripCard: View {
        var body: some View {
            Button(action: {
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                        .shadow(radius: 5)
                        .foregroundColor(.white)
                    VStack {
                        Image(systemName: "plus.circle")
                        Text("Create a new trip")
                    }
                }
            }
            .frame(height: 100)
            .padding([.top, .leading, .trailing])
            .buttonStyle(tapBounceButtonStyle())
        }
    }
    
    var homeToolbar: some View {
        
        Button() {
            // add
        } label: {
            Image(systemName: "plus")
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

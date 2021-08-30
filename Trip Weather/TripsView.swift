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
                    tripCard(trip)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                homeToolbar
            }
        }
    }
    
    @ViewBuilder
    func tripCard(_ trip: TripWeatherModel.STrip) -> some View {
        let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
        if (trip.images.count > 0) {
        }
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
        .frame(height: 300)
        .padding(.all)
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

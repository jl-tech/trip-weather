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
                    let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                    if (trip.images.count > 0) {
                    }
                    ZStack {
                        shape
                            .padding(.all)
                            
                            .foregroundColor(.blue)
                        VStack {
                            Text(trip.name)
                            Text(trip.description)
                            Text(trip.startDate.relativeTime())
                            Text("\(toDateString(from:trip.startDate)) - \(toDateString(from:trip.endDate))")
                        }
                    }
                    .frame(height: 300)
                    
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                homeToolbar
            }
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

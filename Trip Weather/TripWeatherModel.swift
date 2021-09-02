//
//  TripWeatherModel.swift
//  TripWeatherModel
//
//  Created by Jonathan Liu on 30/8/21.
//

import Foundation
import CoreData
import SwiftUI

struct TripWeatherModel {
    @Environment(\.managedObjectContext) var context
    
    struct STrip: Identifiable {
        var name: String
        var description: String
        var startDate: Date
        var endDate: Date
        var timestampAdded: Date
        var locations: [SLocation]
        var image: Data?
        let id: Int
        
    }
    
    struct SLocation: Identifiable {
        var day: Date
        var latitude: Double
        var longitude: Double
        var name: String
        let id: Int
    }
    
    init() {
        // Load from disk
    }
    
    func addTrip(_ trip: Trip) {
        
    }
    
    
}
 

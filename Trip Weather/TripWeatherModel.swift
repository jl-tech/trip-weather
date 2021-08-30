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
        var locations: [Location]
        var images: [Data]
        let id: Int
        
    }
    
    struct SLocation {
        var day: Date
        var location: String
        var name: String
    }
    
    init() {
        // Load from disk
    }
    
    func addTrip(_ trip: Trip) {
        
    }
    
    
}
 

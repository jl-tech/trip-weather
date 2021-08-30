//
//  Trip_WeatherApp.swift
//  Trip Weather
//
//  Created by Jonathan Liu on 30/8/21.
//

import SwiftUI

@main
struct Trip_WeatherApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            BaseView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

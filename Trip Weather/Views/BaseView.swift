//
//  BaseView.swift
//  BaseView
//
//  Created by Jonathan Liu on 30/8/21.
//

import SwiftUI


struct BaseView: View {
    @ObservedObject var viewModel: TripsViewModel = TripsViewModel()
    
    var body: some View {
        TabView {
            NavigationView() {
                TripsView()
                    .navigationBarTitle("Trips")
                    .environmentObject(viewModel)
            }
            .tabItem {
                Image (systemName: "airplane")
                Text("Trips")
            }
            NavigationView() {
                Text("Trip Weather (prototype name) alpha")
            }
            .tabItem {
                Image (systemName: "gear")
                Text("Settings")
            }
            
        }
    }
}

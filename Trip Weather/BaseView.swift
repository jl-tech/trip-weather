//
//  BaseView.swift
//  BaseView
//
//  Created by Jonathan Liu on 30/8/21.
//

import SwiftUI


struct BaseView: View {
    
    
    var body: some View {
        TabView {
            NavigationView() {
                TripsView()
                    .navigationBarTitle("Trips")
            }
            .tabItem {
                Image (systemName: "airplane")
                Text("Trips")
            }
            NavigationView() {
                EmptyView()
            }
            .tabItem {
                Image (systemName: "gear")
                Text("Settings")
            }
            
        }
    }
}

struct BaseView_Previews: PreviewProvider {
    static var previews: some View {
        BaseView()
    }
}

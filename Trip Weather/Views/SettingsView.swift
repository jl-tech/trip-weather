//
//  SettingsView.swift
//  SettingsView
//
//  Created by Jonathan Liu on 6/9/21.
//

import SwiftUI

struct SettingsView: View {
    @State var isUsingImperial: Bool = UserDefaults.standard.bool(forKey: "isUsingImperial")
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Units"), footer: Text("Use imperial units: Fahrenheit and IN and MPH.")) {
                    Toggle("Use imperial units", isOn: $isUsingImperial)
                        .onChange(of: isUsingImperial) { _ in
                            UserDefaults.standard.set(isUsingImperial, forKey: "isUsingImperial")
                        }
                }
                Text("Trip Weather (prototype name) alpha")
                
            }
            .navigationTitle("Settings")
        }
    }
}


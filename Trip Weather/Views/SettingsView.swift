//
//  SettingsView.swift
//  SettingsView
//
//  Created by Jonathan Liu on 6/9/21.
//

import SwiftUI

struct SettingsView: View {
    @State var isUsingImperial: Bool = UserDefaults.standard.bool(forKey: "isUsingImperial")
    @State var locationApproved: Bool = UserDefaults.standard.bool(forKey: "firstLocationRequestApproved")
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Units"), footer: Text("Use imperial units: Fahrenheit and IN and MPH.")) {
                    Toggle("Use Imperial Units", isOn: $isUsingImperial)
                        .onChange(of: isUsingImperial) { _ in
                            UserDefaults.standard.set(isUsingImperial, forKey: "isUsingImperial")
                        }
                }
                Section(header: Text("Features"),
                        footer: Button(action: { }) { Text("Location permissions must also be granted in Settings" )
                }) {
                    Toggle("Use Location Services", isOn: $locationApproved)
                        .onChange(of: locationApproved) { _ in
                            UserDefaults.standard.set(locationApproved, forKey: "firstLocationRequestApproved")
                        }
                }
                Section(header: Text("Data")) {
                    Button(action: {
                        if let bundleID = Bundle.main.bundleIdentifier {
                            UserDefaults.standard.removePersistentDomain(forName: bundleID)
                        }
                    }) {
                        Text("Reset User Settings")
                            .foregroundColor(.red)
                        
                    }
                }
                Text("Trip Weather (prototype name) alpha")
                
            }
            .navigationTitle("Settings")
        }
    }
}


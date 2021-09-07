//
//  FirstLaunchLocationRequestView.swift
//  FirstLaunchLocationRequestView
//
//  Created by Jonathan Liu on 7/9/21.
//

import SwiftUI

struct FirstLocationRequestView: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            Image(systemName: "location.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            Text("Location Services")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom)
            Text("It looks like this trip is in progress!")
            Text("Trip Weather can display weather information while your trips are in progress based on your location.")
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            ZStack {
                RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                    .foregroundColor(.blue)
                Text("Enable Location Services")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(height: 60)
            .padding([.horizontal, .top])
            .onTapGesture {
                UserDefaults.standard.set(true, forKey: "firstLocationRequestDisplayed")
                UserDefaults.standard.set(true, forKey: "firstLocationRequestApproved")
                presentationMode.wrappedValue.dismiss()

            }
            Button(action: {
                UserDefaults.standard.set(true, forKey: "firstLocationRequestDisplayed")
                UserDefaults.standard.set(false, forKey: "firstLocationRequestApproved")
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Don't Enable")
            }
        }
    }
}

struct FirstLaunchLocationRequestView_Previews: PreviewProvider {
    static var previews: some View {
        FirstLocationRequestView()
    }
}

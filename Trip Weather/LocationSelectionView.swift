//
//  LocationSelectionView.swift
//  LocationSelectionView
//
//  Created by Jonathan Liu on 31/8/21.
//

import SwiftUI

struct LocationSelectionView: View {
    @Binding var locations: [TripsViewModel.Location]
    var forDate: Date
    @Binding var completionStatus: AddTripView.DateEntry.status
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

//struct LocationSelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        //LocationSelectionView()
//    }
//}

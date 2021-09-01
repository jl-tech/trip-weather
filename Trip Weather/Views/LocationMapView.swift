//
//  LocationMapView.swift
//  LocationMapView
//
//  Created by Jonathan Liu on 1/9/21.
//

import SwiftUI
import MapKit
import Foundation

struct LocationMapView: View {
    var location: TripsViewModel.Location
    @State private var region: MKCoordinateRegion = MKCoordinateRegion()
    
    struct AnnotationItem: Identifiable {
        var coordinate: CLLocationCoordinate2D
        let id: Int = 0
    }
    

    var body: some View {
        Group {
            ZStack(alignment: .top) {
                Map(coordinateRegion: $region,
                    annotationItems:
                        [CLLocationCoordinate2D(latitude: location.latitude - 0.001, longitude: location.longitude - 0.001)]) { item in
                    MapMarker(coordinate: item)
                }
                VStack {
                    Text("")
                    Text(location.name)
                    Text("")
                }
                .frame(maxWidth: .infinity)
                .cornerRadius(5)
                .background(Blur(style: .systemUltraThinMaterialLight))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.all)

            }
        }
        .onAppear {
            region.center.latitude = location.latitude
            region.center.longitude = location.longitude
            region.span.latitudeDelta = 1.0
            region.span.longitudeDelta = 1.0
        }
        .navigationTitle("Location Map")
        .ignoresSafeArea(edges: [.bottom])
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: Int { 1 }
}


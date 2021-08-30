//
//  TestData.swift
//  TestData
//
//  Created by Jonathan Liu on 30/8/21.
//

import Foundation


func stringToDate(_ date: String) -> Date{
    let dateformatter = DateFormatter()
    dateformatter.dateFormat = "yyyy/MM/dd"
    return dateformatter.date(from: "2021/11/30")!
}

struct TestData {
    static var testTrip = TripWeatherModel.STrip(
        name: "Test Trip!", description: "Description",
        startDate: stringToDate("2021/11/30"),
        endDate: stringToDate("2021/11/30"),
        timestampAdded: Date(),
        locations: [],
        images: [],
        id: 0)
    
    static var testTrips = [testTrip]
    
}

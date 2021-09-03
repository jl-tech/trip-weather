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
    return dateformatter.date(from: date)!
}

struct TestData {
    static var testTrip = TripWeatherModel.Trip(
        name: "Test Trip!", description: "Description",
        startDate: stringToDate("2021/11/30"),
        endDate: stringToDate("2021/11/30"),
        timestampAdded: Date(),
        locations: [],
        image: nil)
    
    static var testTrip2 = TripWeatherModel.Trip(
        name: "Test Trip 2!", description: "Description",
        startDate: stringToDate("2021/12/30"),
        endDate: stringToDate("2021/12/30"),
        timestampAdded: Date(),
        locations: [],
        image: nil)
    
    static var testTrip3 = TripWeatherModel.Trip(
        name: "Test Trip 2 yes yes yes yes yes yes y", description: "Description",
        startDate: stringToDate("2021/12/30"),
        endDate: stringToDate("2021/12/30"),
        timestampAdded: Date(),
        locations: [],
        image: nil)
    static var testTrips = [testTrip, testTrip2, testTrip3]
    
}

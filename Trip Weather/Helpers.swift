//
//  Helpers.swift
//  Helpers
//
//  Created by Jonathan Liu on 30/8/21.
//

import Foundation
import SwiftUI
extension Date {

}


func toLongDateString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .none
    formatter.dateStyle = .medium
    formatter.timeZone = TimeZone.current
    return formatter.string(from: date)
}

func toWeatherKitDateString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

// from https://medium.com/@edwurtle/blur-effect-inside-swiftui-a2e12e61e750
struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}


extension Date: Identifiable {
    public var id: Date {
        self
    }
    
    func relativeTime() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    // from https://newbedev.com/all-dates-between-two-date-objects-swift
    static func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate
        
        while date <= toDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        
        return dates
    }
    
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let diff = Calendar.current.dateComponents([.day], from: date1, to: date2)
        if diff.day == 0 {
            return true
        } else {
            return false
        }
    }
    
    static func isSameDayOrBeforeDate(check: Date, against: Date) -> Bool {
        if isSameDay(check, against) {
            return true
        }
        if check < against {
            return true
        }
        return false
    }
    
    static func isBetweenDates(check: Date, startDate: Date, endDate: Date) -> Bool {
        let checkDate = stripTime(from: check)
        if checkDate >= startDate, checkDate <= endDate {
            return true
        }
        return false
    }
    
    static func stripTime(from originalDate: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: originalDate)
        let date = Calendar.current.date(from: components)
        return date!
    }
}


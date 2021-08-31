//
//  Helpers.swift
//  Helpers
//
//  Created by Jonathan Liu on 30/8/21.
//

import Foundation
import SwiftUI
extension Date {
    func relativeTime() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}


func toDateString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .none
    formatter.dateStyle = .medium
    formatter.timeZone = TimeZone.current
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

// from https://newbedev.com/all-dates-between-two-date-objects-swift
extension Date: Identifiable {
    public var id: Date {
        self
    }
    
    static func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate
        
        while date <= toDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        
        if fromDate != toDate {
            dates.append(toDate)
        }
        return dates
    }
}

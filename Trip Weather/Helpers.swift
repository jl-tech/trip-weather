//
//  Helpers.swift
//  Helpers
//
//  Created by Jonathan Liu on 30/8/21.
//

import Foundation

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
    formatter.dateStyle = .full
    formatter.timeZone = TimeZone.current
    return formatter.string(from: date)
}

//
//  DateExtension.swift
//  CalendarKit
//
//  Created by Prakash Jha on 17/09/25.
//

import Foundation

extension DateFormatter {
    static func formetter(formate: String, timeZone: TimeZone = TimeZone.current) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.timeZone = timeZone
        formatter.dateFormat = formate // newly added
        formatter.locale = Locale.init(identifier: Locale.preferredLanguages[0])
        return formatter
    }
}

extension Date {
    func stringWith(formate: String, timeZone: TimeZone = TimeZone.current) -> String {
        return DateFormatter.formetter(formate: formate).string(from: self)
    }
    
    static func dateFrom(string: String, formate: String, timeZone: TimeZone = TimeZone.current) -> Date? {
        return DateFormatter.formetter(formate: formate).date(from: string)
    }
}

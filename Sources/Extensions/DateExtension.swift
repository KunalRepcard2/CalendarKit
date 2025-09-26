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
    
    
    func firstDayOfMonthWeekday(fullName: Bool = false) -> String? {
        let calendar = Calendar.current
        
        // Get first day of month
        guard let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: self)) else {
            return nil
        }
        
        // Weekday format
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        //Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = fullName ? "EEEE" : "EEE" // EEE = short, EEEE = full
        
        return formatter.string(from: firstDay)
    }
    
    func monthIndexAndYear() -> (month: Int, year: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return (components.month ?? 0, components.year ?? 0)
    }
    
    func weekdayIndex() -> Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self) // 1 = Sunday, 2 = Monday, ...
        // Shift so that Sunday = 0, Monday = 1, ..., Saturday = 6
        return (weekday + 6) % 7
    }
    
    func numberOfDaysInMonth() -> Int? {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: self) else {
            return nil
        }
        return range.count
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var isAWeekend : Bool {
        let weekday = Calendar.current.component(.weekday, from: self)
        return weekday == 7 || weekday == 1
    }
}

//
//  MonthSelectorController.swift
//  CalendarKit
//
//  Created by Prakash Jha on 17/09/25.
//

import UIKit

public final class MonthSelectorController: UIViewController {
    private(set) lazy var monthDaySelector = MonthDaySelectorView()
        
    var pageIndex = 0
    
    var selectedDateIndex: Int {
        get {
            monthDaySelector.selectedDateIndex
        }
        set {
            monthDaySelector.selectedDateIndex = newValue
        }
    }
    
    var monthRepresentDate: Date {
        get {
            monthDaySelector.monthRepresentDate
        }
        set {
            monthDaySelector.monthRepresentDate = newValue
        }
    }
    
    func setDateClickCompletion(_ block: @escaping (Date?) -> Void) {
        self.monthDaySelector.dateClickCompletion = block
    }
    
    func reloadDots() {
//        monthSelector.reloadDots()
    }
    
    override public func loadView() {
        view = monthDaySelector
    }
    
    func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
        monthDaySelector.transitionToHorizontalSizeClass(sizeClass)
    }
}




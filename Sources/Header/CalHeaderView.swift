//
//  CalHeaderPresenter.swift
//  CalendarKit
//
//  Created by Prakash Jha on 22/09/25.
//

import UIKit

protocol CalHeaderViewDelegate: AnyObject {
    func shouldShowDotOn(date: Date) -> Bool
    // called to notify it's parent when any hieght is changed
    // [Mostly happened once number of rows in Month view changed due to the change of days in months and their positions]
    func refreshOnHeightChange()
}


public class CalHeaderView: UIView {
    public let calendar: Calendar
    let daySymbolsView: DaySymbolsView
    private(set) var style = DayHeaderStyle()
  
    var headerDelegate: CalHeaderViewDelegate?
    var selectedDate: Date = Date() {
        didSet {
            if oldValue != selectedDate {
                reloadOnDateChange()
            }
        }
    }
    
    let pagingViewController = UIPageViewController(transitionStyle: .scroll,
                                                    navigationOrientation: .horizontal,
                                                    options: nil)
    
    public init(calendar: Calendar) {
        self.calendar = calendar
        self.daySymbolsView = DaySymbolsView(calendar: calendar)
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateStyle(_ newStyle: DayHeaderStyle) {
        style = newStyle
        daySymbolsView.updateStyle(style.daySymbols)
    }
    
    // change in selected date change
    public func reloadOnDateChange() { }
    
    public func reloadDotsOnPage() { }
    
    public func display(loader: Bool) {
        // add loader in case loading dots in background..
    }
}

public protocol DaySelectorViewDelegate: AnyObject {
    func dateSelectorDidSelectDate(_ date: Date)
    func daySelectorShouldShowDotOn(date: Date) -> Bool
}

public class CalHeaderDaySelecterView: UIView {
    public weak var delegate: DaySelectorViewDelegate?
}


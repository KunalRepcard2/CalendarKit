//
//  CalHeaderPresenter.swift
//  CalendarKit
//
//  Created by Prakash Jha on 22/09/25.
//

import UIKit

protocol CalHeaderViewDelegate: AnyObject {
    func shouldShowDotOn(date: Date) -> Bool
}

public class CalHeaderView: UIView {
    public let calendar: Calendar
    let daySymbolsView: DaySymbolsView
    private(set) var style = DayHeaderStyle()
    var headerDelegate: CalHeaderViewDelegate?
    var selectedDate: Date = Date() {
        didSet {
            reloadOnDateChange()
        }
    }

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
    
    public func reloadOnDateChange() {
        
    }
    
    public func reloadDotsOnPage() {
        
    }
    
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

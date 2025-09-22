//
//  MonthCalDateCellLabel.swift
//  CalendarKit
//
//  Created by Prakash Jha on 22/09/25.
//

import UIKit

class MonthCalDateCellLabel: UILabel {
    private var style = DaySelectorStyle()
    
    var isSelected = false
    var isToday = false
    var isWeekend = false
    var showDot: Bool = false {
        didSet {
            addDotTag(showDot, color: isSelected ? style.selectedDotColor : style.dotColor)
        }
    }
    
    var dayNumber: Int = 0 {
        didSet {
            text = "\(dayNumber)"
        }
    }
    
    public func updateStyle(_ newStyle: DaySelectorStyle) {
        style = newStyle
        self.updateState()
    }

    func updateState() {
        let today = isToday
        if isSelected {
            font = style.todayFont
            textColor = today ? style.todayActiveTextColor : style.activeTextColor
            backgroundColor = today ? style.todayActiveBackgroundColor : style.selectedBackgroundColor
        } else {
            let notTodayColor = isWeekend ? style.weekendTextColor : style.inactiveTextColor
            font = style.font
            textColor = today ? style.todayInactiveTextColor : notTodayColor
            backgroundColor = style.inactiveBackgroundColor
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        CGSize(width: 40, height: 40)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override public func layoutSubviews() {
        layer.cornerRadius = bounds.height / 2
    }
   
    private func configure() {
        isUserInteractionEnabled = true
        textAlignment = .center
        clipsToBounds = true
    }
}

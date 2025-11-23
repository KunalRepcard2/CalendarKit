//
//  MonthCalDateCellLabel.swift
//  CalendarKit
//
//  Created by Prakash Jha on 22/09/25.
//

import UIKit

class MonthCalDateCellLabel: UILabel {
    private var style = DaySelectorStyle()
    private(set) var isSelected = false
    private(set) var dayNumber: Int = 0 {
        didSet {
            text = "\(dayNumber)"
        }
    }
    
    private var isToday = false
    private var isWeekend = false
    private var isPast = false
   
    var showDot: Bool = false {
        didSet {
            addDotTag(showDot, color: isSelected ? style.selectedDotColor : style.dotColor)
        }
    }
    
    class func cellWith(day: Int, month: Int, year: Int, selected: Bool) -> MonthCalDateCellLabel {
        let cell = MonthCalDateCellLabel()
        cell.set(day: day, month: month, year: year, selected: selected)
        return cell
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
        layer.cornerRadius = 8
        //bounds.height / 2
    }
    
    override public var intrinsicContentSize: CGSize {
        CGSize(width: 40, height: 40)
    }
}
    
extension MonthCalDateCellLabel {
    func updateStyle(_ newStyle: DaySelectorStyle) {
        style = newStyle
        self.updateState()
    }
}

private extension MonthCalDateCellLabel {
    private func configure() {
        isUserInteractionEnabled = true
        textAlignment = .center
        clipsToBounds = true
    }
    
    func set(day: Int, month: Int, year: Int, selected: Bool) {
        dayNumber = day
        let date = Date.dateFrom(string: "\(day)-\(month)-\(year)", formate: "dd-MM-yyyy")
        isToday = date?.isToday ?? false
        isWeekend = date?.isAWeekend ?? false
        isPast = date?.isPastDate ?? false
        isSelected = selected
        self.updateState()
    }
    
    
    private func updateState() {
        if isSelected {
            font = style.todayFont
            textColor = isToday ? style.todayActiveTextColor : style.activeTextColor
            backgroundColor = isToday ? style.todayActiveBackgroundColor : style.selectedBackgroundColor
           
//            if !isToday {
//                layer.borderColor = style.selectedBorderColor.cgColor
//                layer.borderWidth = 1
//            } else {
//                layer.borderColor = UIColor.clear.cgColor
//                layer.borderWidth = 0
//            }
        } else {
            let notTodayColor = isWeekend ? style.weekendTextColor : style.inactiveTextColor
            font = style.font
            textColor = isToday ? style.todayInactiveTextColor : notTodayColor
            backgroundColor = style.inactiveBackgroundColor
            
            layer.borderColor = isToday ? style.todayInactiveBorderColor : notTodayColor.cgColor
            layer.borderWidth = isToday ? 1.5 : 0
        }

        addDotTag(showDot, color: isSelected ? style.selectedDotColor : style.dotColor)
    }
}

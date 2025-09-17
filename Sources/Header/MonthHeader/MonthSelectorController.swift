//
//  MonthSelectorController.swift
//  CalendarKit
//
//  Created by Prakash Jha on 17/09/25.
//

import UIKit

public final class MonthSelectorController: UIViewController {
    private(set) lazy var monthSelector = MonthCalCardView(emptyDays: 0)
    
//    public var selectedDate: Date? {
//        get {
//            daySelector.selectedDate
//        }
//        set {
//            daySelector.selectedDate = newValue
//        }
//    }
    
    func setDateClickCompletion(_ block: @escaping (Date?) -> Void) {
        self.monthSelector.dateClickCompletion = block
    }
    
    func reloadDots() {
//        monthSelector.reloadDots()
    }
    
    override public func loadView() {
        view = monthSelector
    }
    
    func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
        monthSelector.transitionToHorizontalSizeClass(sizeClass)
    }
}



class MonthCalCardView: UIView {
    var rows : [MonthCalDateCellView] = []
    var totalHeight: CGFloat = 0
    
    var month = 1
    var year = 2021
    
    private let cellSize: CGFloat = 40
    
    var emptyDaysBeforeFirstDay : Int = 0 // 0
    var dateClickCompletion: ((Date?) -> Void)?

    
    private var daysInMonth: Int {
        return 30
    }
    
    init(emptyDays: Int) {
        self.emptyDaysBeforeFirstDay = emptyDays
        super.init(frame: .zero)
        initializeViews()
        configureDate()
        backgroundColor = .white
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
        initializeViews()
    }
    
    @objc private func dateLabelDidTap(_ sender: UITapGestureRecognizer) {
        if let cell = sender.view as? MonthCalDateCellView {
            dateClickCompletion?(Date.dateFrom(string: "\(cell)-\(month)-\(year)", formate: "dd-mm-yyyy"))
        }
    }
    
    private func initializeViews() {
        // Store last selected date
//        let lastSelectedDate = selectedDate
        
        // Remove previous Items
        rows.forEach{$0.removeFromSuperview()}
        rows.removeAll()
        
        // Create new with corresponding class
        for i in 1...daysInMonth {
            let cell = MonthCalDateCellView()
            cell.dayNumber = i
            //Date.dateFrom(string: "\(i)-\(month)-\(year)", formate: "dd-mm-yyyy") ?? Date()
            rows.append(cell)
            addSubview(cell)
            cell.updateState()
            
            let recognizer = UITapGestureRecognizer(target: self,
                                                    action: #selector(MonthCalCardView.dateLabelDidTap(_:)))
            cell.addGestureRecognizer(recognizer)
        }
        configureDate()
//        updateItemsCalendar()
        // Restore last date
//        selectedDate = lastSelectedDate
    }
    
    private func configureDate() {
//        for (increment, label) in items.enumerated() {
//            let lDate = calendar.date(byAdding: .day, value: increment, to: startDate)!
//            label.showDot = self.delegate?.showDotOnDate(lDate) ?? false
//            label.date = lDate
//        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let accpiedW = cellSize * 7
        let gap = (frame.width -  accpiedW) / CGFloat(8) // counted 6 + start + end
        
        let max = daysInMonth + emptyDaysBeforeFirstDay
        
            
        let emptyXMargin = CGFloat(CGFloat(cellSize) + gap) * CGFloat(emptyDaysBeforeFirstDay)
        var xx = emptyXMargin + gap
        var yy: CGFloat = 5.0
        let sz = CGSize(width: cellSize, height: cellSize)
        
        var indx = emptyDaysBeforeFirstDay
        while indx <= max {
            if rows.count <= indx {
                break
            }
            let cellV = rows[indx]
            cellV.frame = CGRect(origin: CGPoint(x: xx, y: yy), size: sz)
            xx += cellSize + gap
            
            if (indx + 1) % 7 == 0 { // last row reset
                xx = gap
                yy += cellSize
            }
            indx += 1
        }
    }
}

class MonthCalDateCellView: UILabel {
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
    
   
    private func configure() {
        isUserInteractionEnabled = true
        textAlignment = .center
        clipsToBounds = true
    }
}
